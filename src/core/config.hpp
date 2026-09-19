#pragma once

#include "shortcut.hpp"

#include <filesystem>
#include <string>
#include <vector>

namespace oatmeal {

struct ShortcutConfig {
  Shortcut shortcut;
  std::string label;
  bool enabled = true;
};

std::vector<ShortcutConfig> default_shortcuts();
std::vector<ShortcutConfig> load_config(const std::filesystem::path &path);
bool write_default_config(const std::filesystem::path &path);
bool write_config(const std::filesystem::path &path,
                  const std::vector<ShortcutConfig> &shortcuts);

} // namespace oatmeal
