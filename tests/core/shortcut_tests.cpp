#include <cassert>

#include "core/shortcut/shortcut.hpp"

using namespace oatmeal;

int main() {
  const auto shortcut = parse_shortcut("cmd+shift+z");
  assert(shortcut.has_value());
  assert(shortcut->key == "z");
  assert(format_shortcut(*shortcut) == "⌘ ⇧ Z");
  assert(parse_shortcut("command+alt+escape")->modifiers ==
         (modifier_mask(Modifier::Command) | modifier_mask(Modifier::Option)));
  assert(!parse_shortcut("cmd+shift"));
}
