#pragma once

#include "shortcut.hpp"

#include <chrono>
#include <optional>

namespace oatmeal {

class TriggerAggregator {
public:
  explicit TriggerAggregator(
      std::chrono::milliseconds window = std::chrono::milliseconds(650))
      : window_(window) {}

  int record(const Shortcut &shortcut,
             std::chrono::steady_clock::time_point now);

private:
  std::chrono::milliseconds window_;
  std::optional<Shortcut> last_shortcut_;
  std::chrono::steady_clock::time_point last_time_{};
  int count_ = 0;
};

} // namespace oatmeal
