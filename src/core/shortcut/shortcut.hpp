#pragma once

#include <cstdint>
#include <optional>
#include <string>
#include <string_view>

namespace oatmeal {

enum class Modifier : std::uint8_t {
  Command = 1 << 0,
  Control = 1 << 1,
  Option = 1 << 2,
  Shift = 1 << 3,
  Function = 1 << 4,
};

using ModifierMask = std::uint8_t;

struct Shortcut {
  ModifierMask modifiers = 0;
  std::string key;

  bool operator==(const Shortcut &) const = default;
};

std::optional<Shortcut> parse_shortcut(std::string_view value);
std::string format_shortcut(const Shortcut &shortcut);
ModifierMask modifier_mask(Modifier modifier);

} // namespace oatmeal
