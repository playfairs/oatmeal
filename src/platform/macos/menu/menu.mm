#import <AppKit/AppKit.h>

#include "platform/macos/menu/menu.hpp"
#include "platform/macos/settings/settings.hpp"

@interface MenuController : NSObject
@end

@implementation MenuController
- (void)showSettings:(id)sender {
  oatmeal::show_settings_window();
}
- (void)quitOatmeal:(id)sender {
  [NSApp terminate:nil];
}
@end

namespace oatmeal {

void install_menu_bar(SettingsModel &model, Overlay &overlay, Listener &listener) {
  install_settings_ui(model, overlay, listener);
  NSStatusItem *status_item = [[NSStatusBar systemStatusBar]
      statusItemWithLength:NSVariableStatusItemLength];
  status_item.button.image = [NSImage imageWithSystemSymbolName:@"keyboard"
                                       accessibilityDescription:@"Oatmeal"];
  if (status_item.button.image == nil)
    status_item.button.title = @"⌘";
  status_item.button.toolTip = @"Oatmeal";
  MenuController *menu_controller = [MenuController new];
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Oatmeal"];
  NSMenuItem *settings =
      [[NSMenuItem alloc] initWithTitle:@"Settings…"
                                 action:@selector(showSettings:)
                          keyEquivalent:@","];
  settings.target = menu_controller;
  [menu addItem:settings];
  [menu addItem:[NSMenuItem separatorItem]];
  NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit Oatmeal"
                                                action:@selector(quitOatmeal:)
                                         keyEquivalent:@"q"];
  quit.target = menu_controller;
  [menu addItem:quit];
  status_item.menu = menu;
}

} // namespace oatmeal
