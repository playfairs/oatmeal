#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>

#include "platform/macos/input/listener.hpp"

#include <iostream>
#include <string>
#include <utility>

namespace oatmeal {

struct Listener::Impl {
  Impl(const std::vector<ShortcutConfig> &shortcuts, Handler handler)
      : shortcuts(shortcuts), handler(std::move(handler)) {}

  ~Impl() {
    if (global_monitor != nil)
      [NSEvent removeMonitor:global_monitor];
    if (source != nullptr)
      CFRunLoopRemoveSource(CFRunLoopGetMain(), source, kCFRunLoopCommonModes);
    if (source != nullptr)
      CFRelease(source);
    if (tap != nullptr)
      CFRelease(tap);
  }

  bool start() {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt : @YES};
    AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    CGEventMask mask = CGEventMaskBit(kCGEventKeyDown);
    tap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap,
                           kCGEventTapOptionListenOnly, mask,
                           &Listener::Impl::event_callback, this);
    if (tap != nullptr) {
      source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
      CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopCommonModes);
      CGEventTapEnable(tap, true);
      return true;
    }

    global_monitor = [NSEvent
        addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                      handler:^(NSEvent *event) {
                                        ModifierMask modifiers = 0;
                                        const auto flags = event.modifierFlags;
                                        if (flags & NSEventModifierFlagCommand)
                                          modifiers |=
                                              modifier_mask(Modifier::Command);
                                        if (flags & NSEventModifierFlagControl)
                                          modifiers |=
                                              modifier_mask(Modifier::Control);
                                        if (flags & NSEventModifierFlagOption)
                                          modifiers |=
                                              modifier_mask(Modifier::Option);
                                        if (flags & NSEventModifierFlagShift)
                                          modifiers |=
                                              modifier_mask(Modifier::Shift);
                                        if (flags & NSEventModifierFlagFunction)
                                          modifiers |=
                                              modifier_mask(Modifier::Function);
                                        handle_key_event(
                                            static_cast<unsigned short>(
                                                event.keyCode),
                                            modifiers);
                                      }];
    if (global_monitor != nil)
      return true;

    std::cerr << "Unable to monitor keyboard shortcuts. Enable Oatmeal in "
                 "System Settings > Privacy & Security > Input Monitoring.\n";
    return false;
  }

  void set_shortcuts(const std::vector<ShortcutConfig> &updated) {
    shortcuts = updated;
  }

  static CGEventRef event_callback(CGEventTapProxy, CGEventType,
                                   CGEventRef event, void *refcon) {
    auto *listener = static_cast<Listener::Impl *>(refcon);
    const auto keycode = static_cast<unsigned short>(
        CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode));
    ModifierMask modifiers = 0;
    const auto flags = CGEventGetFlags(event);
    if (flags & kCGEventFlagMaskCommand)
      modifiers |= modifier_mask(Modifier::Command);
    if (flags & kCGEventFlagMaskControl)
      modifiers |= modifier_mask(Modifier::Control);
    if (flags & kCGEventFlagMaskAlternate)
      modifiers |= modifier_mask(Modifier::Option);
    if (flags & kCGEventFlagMaskShift)
      modifiers |= modifier_mask(Modifier::Shift);
    if (flags & kCGEventFlagMaskSecondaryFn)
      modifiers |= modifier_mask(Modifier::Function);
    listener->handle_key_event(keycode, modifiers);
    return event;
  }

  void handle_key_event(unsigned short keycode, ModifierMask modifiers) {
    const auto key = key_for_code(keycode);
    if (key.empty())
      return;
    Shortcut pressed{modifiers, key};
    for (const auto &shortcut : shortcuts) {
      if (shortcut.enabled && shortcut.shortcut == pressed)
        handler(shortcut);
    }
  }

  static std::string key_for_code(unsigned short code) {
    static const char *keys[] = {
        "a",     "s",  "d",      "f",      "h",     "g",    "z",    "x",
        "c",     "v",  "b",      "q",      "w",     "e",    "r",    "y",
        "t",     "1",  "2",      "3",      "4",     "6",    "5",    "=",
        "9",     "7",  "-",      "8",      "0",     "]",    "o",    "u",
        "[",     "i",  "p",      "return", "l",     "j",    "'",    "k",
        ";",     "\\", "comma",  "/",      "n",     "m",    ".",    "tab",
        "space", "`",  "delete", "escape", "right", "left", "down", "up"};
    return code < sizeof(keys) / sizeof(keys[0]) ? keys[code] : std::string{};
  }

  std::vector<ShortcutConfig> shortcuts;
  Handler handler;
  CFMachPortRef tap = nullptr;
  CFRunLoopSourceRef source = nullptr;
  id global_monitor = nil;
};

Listener::Listener(const std::vector<ShortcutConfig> &shortcuts,
                   Handler handler)
    : impl_(std::make_unique<Impl>(shortcuts, std::move(handler))) {}

Listener::~Listener() = default;

bool Listener::start() { return impl_->start(); }

void Listener::set_shortcuts(const std::vector<ShortcutConfig> &shortcuts) {
  impl_->set_shortcuts(shortcuts);
}

} // namespace oatmeal
