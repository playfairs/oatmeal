#pragma once

#include <string>
#include <string_view>

namespace oatmeal {

enum class OverlayTheme { Dark, Light, Graphite };
enum class OverlayPosition { TopCenter, BottomCenter, TopLeft, TopRight };

struct OverlaySettings {
  OverlayTheme theme = OverlayTheme::Dark;
  OverlayPosition position = OverlayPosition::TopCenter;
  double duration = 1.15;
};

class Overlay {
 public:
  virtual ~Overlay() = default;
  virtual void show(std::string_view shortcut, std::string_view label, int count) = 0;
  virtual void set_settings(const OverlaySettings& settings) = 0;
};

}  // namespace oatmeal
