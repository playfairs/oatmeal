#include "core/shortcut/shortcut.hpp"

#include <algorithm>
#include <cctype>
#include <sstream>
#include <vector>

namespace oatmeal {
namespace {

std::string lower(std::string_view value) {
  std::string result(value);
  std::transform(result.begin(), result.end(), result.begin(), [](unsigned char character) {
    return static_cast<char>(std::tolower(character));
  });
  return result;
}

std::vector<std::string> split(std::string_view value) {
  std::vector<std::string> parts;
  std::size_t start = 0;
  while (start <= value.size()) {
    const auto end = value.find('+', start);
    parts.emplace_back(value.substr(start, end == std::string_view::npos ? end : end - start));
    if (end == std::string_view::npos) {
      break;
    }
    start = end + 1;
  }
  return parts;
}

std::string display_key(std::string key) {
  if (key.size() == 1) {
    key[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(key[0])));
  } else if (key == "escape") {
    key = "Esc";
  }
  return key;
}

}  // namespace

ModifierMask modifier_mask(Modifier modifier) {
  return static_cast<ModifierMask>(modifier);
}

std::optional<Shortcut> parse_shortcut(std::string_view value) {
  Shortcut shortcut;
  bool has_key = false;
  for (const auto& raw_part : split(value)) {
    const auto part = lower(raw_part);
    if (part.empty()) {
      return std::nullopt;
    }
    if (part == "cmd" || part == "command") {
      shortcut.modifiers |= modifier_mask(Modifier::Command);
    } else if (part == "ctrl" || part == "control") {
      shortcut.modifiers |= modifier_mask(Modifier::Control);
    } else if (part == "option" || part == "alt") {
      shortcut.modifiers |= modifier_mask(Modifier::Option);
    } else if (part == "shift") {
      shortcut.modifiers |= modifier_mask(Modifier::Shift);
    } else if (part == "fn" || part == "function") {
      shortcut.modifiers |= modifier_mask(Modifier::Function);
    } else if (!has_key) {
      shortcut.key = part;
      has_key = true;
    } else {
      return std::nullopt;
    }
  }
  if (!has_key) {
    return std::nullopt;
  }
  return shortcut;
}

std::string format_shortcut(const Shortcut& shortcut) {
  std::string result;
  if (shortcut.modifiers & modifier_mask(Modifier::Command))
    result += "⌘ ";
  if (shortcut.modifiers & modifier_mask(Modifier::Control))
    result += "⌃ ";
  if (shortcut.modifiers & modifier_mask(Modifier::Option))
    result += "⌥ ";
  if (shortcut.modifiers & modifier_mask(Modifier::Shift))
    result += "⇧ ";
  if (shortcut.modifiers & modifier_mask(Modifier::Function))
    result += "fn ";
  result += display_key(shortcut.key);
  return result;
}

}  // namespace oatmeal
