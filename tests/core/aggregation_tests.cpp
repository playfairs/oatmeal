#include <cassert>
#include <chrono>

#include "core/aggregation/aggregation.hpp"

using namespace oatmeal;

int main() {
  TriggerAggregator aggregator;
  const auto start = std::chrono::steady_clock::now();
  assert(aggregator.record(*parse_shortcut("cmd+c"), start) == 1);
  assert(aggregator.record(*parse_shortcut("cmd+c"), start + std::chrono::milliseconds(100)) == 2);
  assert(aggregator.record(*parse_shortcut("cmd+v"), start + std::chrono::milliseconds(150)) == 1);
  assert(aggregator.record(*parse_shortcut("cmd+v"), start + std::chrono::seconds(1)) == 1);
}
