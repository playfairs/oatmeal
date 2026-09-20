#pragma once

#include "application/overlay.hpp"
#include "core/config/config.hpp"

#include <filesystem>
#include <string>
#include <vector>

namespace oatmeal {

class Listener;

class SettingsModel {
public:
  static SettingsModel load(const std::filesystem::path &config_path);

  bool save() const;

  std::filesystem::path config_path;
  std::filesystem::path preferences_path;
  std::filesystem::path launch_agent_path;
  std::vector<ShortcutConfig> shortcuts;
  OverlaySettings overlay;
  bool launch_on_login = false;
};

void install_settings_ui(SettingsModel& model, Overlay& overlay, Listener& listener);
void show_settings_window();

} // namespace oatmeal
