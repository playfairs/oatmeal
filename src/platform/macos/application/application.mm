#import <AppKit/AppKit.h>

#include "core/aggregation/aggregation.hpp"
#include "core/config/config.hpp"
#include "platform/macos/application/application.hpp"
#include "platform/macos/input/listener.hpp"
#include "platform/macos/menu/menu.hpp"
#include "platform/macos/overlay/overlay.hpp"
#include "platform/macos/settings/settings.hpp"

#include <chrono>
#include <filesystem>
#include <memory>
#include <string>

namespace oatmeal {

int run() {
  @autoreleasepool {
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    const auto config_path =
        std::filesystem::path(std::string([[NSHomeDirectory()
            stringByAppendingPathComponent:
                @"Library/Application Support/Oatmeal/shortcuts.conf"]
            UTF8String]));
    if (!std::filesystem::exists(config_path))
      oatmeal::write_default_config(config_path);
    auto settings = oatmeal::SettingsModel::load(config_path);
    auto overlay = oatmeal::create_overlay();
    overlay->set_settings(settings.overlay);
    oatmeal::TriggerAggregator aggregator;
    oatmeal::Listener listener(
        settings.shortcuts, [&](const oatmeal::ShortcutConfig &config) {
          const auto count = aggregator.record(
              config.shortcut, std::chrono::steady_clock::now());
          overlay->show(oatmeal::format_shortcut(config.shortcut), config.label,
                        count);
        });
    listener.start();
    oatmeal::install_menu_bar(settings, *overlay, listener);
    [NSApp run];
  }
  return 0;
}

} // namespace oatmeal
