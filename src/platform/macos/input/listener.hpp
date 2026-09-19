#pragma once

#include "core/config.hpp"

#include <functional>
#include <memory>
#include <vector>

namespace oatmeal {

class Listener {
public:
  using Handler = std::function<void(const ShortcutConfig &)>;

  Listener(const std::vector<ShortcutConfig> &shortcuts, Handler handler);
  ~Listener();

  Listener(const Listener &) = delete;
  Listener &operator=(const Listener &) = delete;

  bool start();
  void set_shortcuts(const std::vector<ShortcutConfig> &shortcuts);

private:
  struct Impl;
  std::unique_ptr<Impl> impl_;
};

} // namespace oatmeal
