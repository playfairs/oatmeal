#pragma once

#include <vector>

#include "application/overlay.hpp"
#include "platform/macos/input/listener.hpp"
#include "platform/macos/settings/settings.hpp"

namespace oatmeal {

void install_menu_bar(SettingsModel& model, Overlay& overlay, Listener& listener);

}  // namespace oatmeal
