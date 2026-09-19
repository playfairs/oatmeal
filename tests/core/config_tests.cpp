#include "core/config.hpp"

#include <cassert>
#include <filesystem>
#include <fstream>

using namespace oatmeal;

int main() {
  const auto path =
      std::filesystem::temp_directory_path() / "oatmeal-config-test.conf";
  assert(write_default_config(path));
  const auto entries = load_config(path);
  assert(entries.size() == 3);
  assert(entries[0].shortcut == *parse_shortcut("cmd+c"));
  assert(entries[1].shortcut == *parse_shortcut("cmd+v"));
  assert(entries[2].shortcut == *parse_shortcut("cmd+z"));
  assert(entries.front().label == "Clicked");

  {
    std::ofstream custom(path);
    custom << "shortcuts {\n    \"ctrl+c\" {\n        label = \"Interrupt\"\n  "
              "      enabled = false\n    }\n}\n";
  }
  const auto custom_entries = load_config(path);
  assert(custom_entries.size() == 1);
  assert(custom_entries.front().shortcut == *parse_shortcut("ctrl+c"));
  assert(custom_entries.front().label == "Interrupt");
  assert(!custom_entries.front().enabled);
  std::filesystem::remove(path);
}
