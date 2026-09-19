#include "aggregation.hpp"

namespace oatmeal {

int TriggerAggregator::record(const Shortcut &shortcut,
                              std::chrono::steady_clock::time_point now) {
  if (last_shortcut_ && *last_shortcut_ == shortcut &&
      now - last_time_ <= window_) {
    ++count_;
  } else {
    last_shortcut_ = shortcut;
    count_ = 1;
  }
  last_time_ = now;
  return count_;
}

} // namespace oatmeal
