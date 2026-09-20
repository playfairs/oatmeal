#include "core/config/config.hpp"

#include <array>
#include <fstream>
#include <regex>

namespace oatmeal {
namespace {

std::string config_key(const Shortcut &shortcut) {
  std::string result;
  if (shortcut.modifiers & modifier_mask(Modifier::Command))
    result += "cmd+";
  if (shortcut.modifiers & modifier_mask(Modifier::Control))
    result += "ctrl+";
  if (shortcut.modifiers & modifier_mask(Modifier::Option))
    result += "option+";
  if (shortcut.modifiers & modifier_mask(Modifier::Shift))
    result += "shift+";
  if (shortcut.modifiers & modifier_mask(Modifier::Function))
    result += "fn+";
  return result + shortcut.key;
}

std::string trim(std::string value) {
  const auto first = value.find_first_not_of(" \t\r\n");
  if (first == std::string::npos)
    return {};
  const auto last = value.find_last_not_of(" \t\r\n");
  return value.substr(first, last - first + 1);
}

std::string quoted_value(const std::string &line) {
  const auto first = line.find('"');
  const auto last = line.rfind('"');
  return first == std::string::npos || last <= first
             ? std::string{}
             : line.substr(first + 1, last - first - 1);
}

bool is_legacy_default(const std::vector<ShortcutConfig> &entries) {
  if (entries.size() != 6)
    return false;
  const auto expected = std::array{
      std::pair{"cmd+c", "Clicked"}, std::pair{"cmd+v", "Pasted"},
      std::pair{"cmd+x", "Cut"},     std::pair{"cmd+s", "Saved"},
      std::pair{"cmd+z", "Undo"},    std::pair{"cmd+shift+z", "Redo"},
  };
  for (std::size_t index = 0; index < expected.size(); ++index) {
    const auto parsed = parse_shortcut(expected[index].first);
    const bool legacy_click_label =
        index == 0 &&
        (entries[index].label == "Copied" || entries[index].label == "Clicked");
    if (!parsed || entries[index].shortcut != *parsed ||
        (!legacy_click_label &&
         entries[index].label != expected[index].second) ||
        !entries[index].enabled) {
      return false;
    }
  }
  return true;
}

} // namespace

std::vector<ShortcutConfig> default_shortcuts() {
  return {
      {*parse_shortcut("cmd+c"), "Clicked", true},
      {*parse_shortcut("cmd+v"), "Pasted", true},
      {*parse_shortcut("cmd+z"), "Undo", true},
  };
}

std::vector<ShortcutConfig> load_config(const std::filesystem::path &path) {
  std::ifstream input(path);
  if (!input)
    return default_shortcuts();

  std::vector<ShortcutConfig> result;
  std::string line;
  ShortcutConfig *current = nullptr;
  while (std::getline(input, line)) {
    line = trim(line);
    if (line.empty() || line.starts_with('#'))
      continue;
    if (line.front() == '"' && line.back() == '{') {
      const auto key = quoted_value(line);
      const auto parsed = parse_shortcut(key);
      if (!parsed) {
        current = nullptr;
        continue;
      }
      result.push_back({*parsed, {}, true});
      current = &result.back();
    } else if (current != nullptr && line.starts_with("label")) {
      current->label = quoted_value(line);
    } else if (current != nullptr && line.starts_with("enabled")) {
      current->enabled = line.find("true") != std::string::npos;
    } else if (line == "}") {
      current = nullptr;
    }
  }
  if (result.empty() || is_legacy_default(result))
    return default_shortcuts();
  return result;
}

bool write_default_config(const std::filesystem::path &path) {
  return write_config(path, default_shortcuts());
}

bool write_config(const std::filesystem::path &path,
                  const std::vector<ShortcutConfig> &shortcuts) {
  std::error_code error;
  std::filesystem::create_directories(path.parent_path(), error);
  std::ofstream output(path);
  if (!output)
    return false;
  output << "# Shortcuts use cmd, ctrl, option, shift, and fn "
            "modifiers.\nshortcuts {\n";
  for (const auto &entry : shortcuts) {
    output << "    \"" << config_key(entry.shortcut) << "\" {\n";
    output << "        label = \"" << entry.label
           << "\"\n        enabled = true\n    }\n";
  }
  output << "}\n";
  return true;
}

} // namespace oatmeal
