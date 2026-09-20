#import <AppKit/AppKit.h>
#import <mach-o/dyld.h>

#include "platform/macos/settings/settings.hpp"
#include "platform/macos/settings/settings_bridge.h"
#include "platform/macos/input/listener.hpp"

#include <algorithm>
#include <fstream>
#include <sstream>
#include <unistd.h>

extern "C" void oatmeal_swift_show_settings(const char *shortcuts, int32_t theme,
                                             int32_t position, double duration,
                                             int32_t launch_on_login,
                                             OatmealSettingsCallback callback);

namespace oatmeal {
namespace {

SettingsModel *active_model = nullptr;
Overlay *active_overlay = nullptr;
Listener *active_listener = nullptr;

std::string value_for(const std::filesystem::path &path, const std::string &key) {
  std::ifstream input(path);
  std::string line;
  while (std::getline(input, line)) {
    if (line.rfind(key + "=", 0) == 0)
      return line.substr(key.size() + 1);
  }
  return {};
}

std::string config_key(const Shortcut &shortcut) {
  std::string result;
  if (shortcut.modifiers & modifier_mask(Modifier::Command)) result += "cmd+";
  if (shortcut.modifiers & modifier_mask(Modifier::Control)) result += "ctrl+";
  if (shortcut.modifiers & modifier_mask(Modifier::Option)) result += "option+";
  if (shortcut.modifiers & modifier_mask(Modifier::Shift)) result += "shift+";
  if (shortcut.modifiers & modifier_mask(Modifier::Function)) result += "fn+";
  return result + shortcut.key;
}

std::string shortcut_payload() {
  std::ostringstream output;
  for (const auto &entry : active_model->shortcuts) {
    output << config_key(entry.shortcut) << "|" << entry.label << "|"
           << (entry.enabled ? "1" : "0") << "\n";
  }
  return output.str();
}

std::filesystem::path executable_path() {
  return std::filesystem::path("/Applications/Oatmeal.app");
}

bool run_launchctl(const std::vector<std::string> &arguments) {
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = @"/bin/launchctl";
  NSMutableArray<NSString *> *task_arguments = [NSMutableArray array];
  for (const auto &argument : arguments)
    [task_arguments addObject:[NSString stringWithUTF8String:argument.c_str()]];
  task.arguments = task_arguments;
  @try {
    [task launch];
    [task waitUntilExit];
  } @catch (NSException *) {
    return false;
  }
  return task.terminationStatus == 0;
}

bool sync_launch_agent(const SettingsModel &model) {
  if (getuid() == 0) return true;

  std::error_code error;
  std::filesystem::create_directories(model.launch_agent_path.parent_path(), error);
  const std::string label = "com.oatmeal.app";
  const std::string domain = "gui/" + std::to_string(getuid());

  if (std::filesystem::exists(model.launch_agent_path)) {
    run_launchctl({"bootout", domain + "/" + label});
  }

  if (!model.launch_on_login) {
    std::filesystem::remove(model.launch_agent_path, error);
    return true;
  }

  const auto executable = executable_path();
  if (executable.empty()) return false;

  const auto plist = std::string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n") +
                    "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" "
                    "\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
                    "<plist version=\"1.0\"><dict>\n" +
                    "<key>Label</key><string>com.oatmeal.app</string>\n" +
                    "<key>ProgramArguments</key><array><string>/usr/bin/open</string><string>-a</string><string>" +
                    executable.string() + "</string></array>\n" +
                    "<key>RunAtLoad</key><true/>\n" +
                    "<key>ProcessType</key><string>Background</string>\n" +
                    "</dict></plist>\n";

  std::ofstream output(model.launch_agent_path);
  if (!output) return false;
  output << plist;
  output.close();

  const auto print = std::string("print ") + domain;
  const auto print_ok = run_launchctl({"print", domain});
  if (!print_ok) return true;
  return run_launchctl({"bootstrap", domain, model.launch_agent_path.string()});
}

void apply_settings() {
  active_model->save();
  active_listener->set_shortcuts(active_model->shortcuts);
  active_overlay->set_settings(active_model->overlay);
}

void swift_callback(int32_t action, int32_t index, const char *value) {
  if (active_model == nullptr) return;
  const auto item = static_cast<std::size_t>(index);
  switch (action) {
  case 1:
    if (item < active_model->shortcuts.size()) active_model->shortcuts[item].enabled = value != nullptr && std::string(value) == "1";
    break;
  case 2:
    if (item < active_model->shortcuts.size()) active_model->shortcuts[item].label = value != nullptr ? value : "";
    break;
  case 3:
    if (item < active_model->shortcuts.size()) active_model->shortcuts.erase(active_model->shortcuts.begin() + item);
    break;
  case 4:
    active_model->overlay.theme = static_cast<OverlayTheme>(index);
    break;
  case 5:
    active_model->overlay.position = static_cast<OverlayPosition>(index);
    break;
  case 6:
    if (value != nullptr) active_model->overlay.duration = std::max(0.25, std::stod(value));
    break;
  case 7:
    if (value != nullptr) {
      const auto parsed = parse_shortcut(value);
      if (parsed) active_model->shortcuts.push_back({*parsed, parsed->key, true});
    }
    break;
  case 8:
    break;
  case 9:
    active_model->launch_on_login = index != 0;
    sync_launch_agent(*active_model);
    break;
  default:
    return;
  }
  apply_settings();
}

} // namespace

SettingsModel SettingsModel::load(const std::filesystem::path &config_path) {
  SettingsModel model;
  model.config_path = config_path;
  model.preferences_path = config_path.parent_path() / "preferences.conf";
  model.launch_agent_path = std::filesystem::path(std::string([[NSHomeDirectory() stringByAppendingPathComponent:@"Library/LaunchAgents/com.oatmeal.app.plist"] UTF8String]));
  model.shortcuts = load_config(config_path);
  model.launch_on_login = std::filesystem::exists(model.launch_agent_path);

  const auto theme = value_for(model.preferences_path, "theme");
  if (theme == "light") model.overlay.theme = OverlayTheme::Light;
  else if (theme == "graphite") model.overlay.theme = OverlayTheme::Graphite;

  const auto position = value_for(model.preferences_path, "position");
  if (position == "bottom-center") model.overlay.position = OverlayPosition::BottomCenter;
  else if (position == "top-left") model.overlay.position = OverlayPosition::TopLeft;
  else if (position == "top-right") model.overlay.position = OverlayPosition::TopRight;

  const auto duration = value_for(model.preferences_path, "duration");
  if (!duration.empty()) model.overlay.duration = std::max(0.25, std::stod(duration));
  return model;
}

bool SettingsModel::save() const {
  if (!write_config(config_path, shortcuts)) return false;
  std::ofstream output(preferences_path);
  if (!output) return false;
  const char *theme = overlay.theme == OverlayTheme::Light ? "light" : overlay.theme == OverlayTheme::Graphite ? "graphite" : "dark";
  const char *position = overlay.position == OverlayPosition::BottomCenter ? "bottom-center" : overlay.position == OverlayPosition::TopLeft ? "top-left" : overlay.position == OverlayPosition::TopRight ? "top-right" : "top-center";
  output << "theme=" << theme << "\nposition=" << position << "\nduration=" << overlay.duration << "\n";
  return true;
}

void install_settings_ui(SettingsModel &model, Overlay &overlay, Listener &listener) {
  active_model = &model;
  active_overlay = &overlay;
  active_listener = &listener;
}

void show_settings_window() {
  const auto payload = shortcut_payload();
  oatmeal_swift_show_settings(payload.c_str(), static_cast<int32_t>(active_model->overlay.theme), static_cast<int32_t>(active_model->overlay.position), active_model->overlay.duration, active_model->launch_on_login ? 1 : 0, &swift_callback);
}

} // namespace oatmeal
