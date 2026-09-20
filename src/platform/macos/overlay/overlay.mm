#include "platform/macos/overlay/overlay.hpp"

#import <AppKit/AppKit.h>

#include <string>

#include "application/overlay.hpp"

@interface OatmealPanel : NSPanel
@end

@implementation OatmealPanel
- (BOOL)canBecomeKeyWindow {
  return NO;
}
- (BOOL)canBecomeMainWindow {
  return NO;
}
@end

@interface OverlayView : NSView
@property(nonatomic, copy) NSString *shortcutText;
@property(nonatomic, copy) NSString *labelText;
@property(nonatomic) NSInteger count;
@property(nonatomic, strong) NSColor *backgroundColor;
@property(nonatomic) BOOL darkText;
@end

@implementation OverlayView
- (void)drawRect:(NSRect)rect {
  [super drawRect:rect];
  NSBezierPath *background = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                             xRadius:14
                                                             yRadius:14];
  [[self.backgroundColor colorWithAlphaComponent:0.88] setFill];
  [background fill];
  [[[[NSColor whiteColor] colorWithAlphaComponent:0.14]
      colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] setStroke];
  [background setLineWidth:1];
  [background stroke];

  NSMutableString *title = [self.shortcutText mutableCopy];
  if (self.count > 1)
    [title appendFormat:@" x%ld", (long)self.count];
  NSDictionary *titleAttributes = @{
    NSFontAttributeName : [NSFont systemFontOfSize:18 weight:NSFontWeightMedium],
    NSForegroundColorAttributeName : self.darkText ? [NSColor blackColor] : [NSColor whiteColor]
  };
  NSDictionary *labelAttributes = @{
    NSFontAttributeName : [NSFont systemFontOfSize:12 weight:NSFontWeightRegular],
    NSForegroundColorAttributeName :
        [(self.darkText ? [NSColor blackColor] : [NSColor whiteColor]) colorWithAlphaComponent:0.72]
  };
  NSSize titleSize = [title sizeWithAttributes:titleAttributes];
  NSRect titleRect = NSMakeRect((NSWidth(self.bounds) - titleSize.width) / 2,
                                NSHeight(self.bounds) - 34, titleSize.width, titleSize.height);
  [title drawInRect:titleRect withAttributes:titleAttributes];
  if (self.labelText.length > 0) {
    NSSize labelSize = [self.labelText sizeWithAttributes:labelAttributes];
    NSRect labelRect = NSMakeRect((NSWidth(self.bounds) - labelSize.width) / 2, 13, labelSize.width,
                                  labelSize.height);
    [self.labelText drawInRect:labelRect withAttributes:labelAttributes];
  }
}
@end

namespace oatmeal {

class MacOverlay final : public Overlay {
 public:
  MacOverlay() {
    panel_ = [[OatmealPanel alloc]
        initWithContentRect:NSMakeRect(0, 0, 180, 74)
                  styleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskNonactivatingPanel
                    backing:NSBackingStoreBuffered
                      defer:NO];
    panel_.opaque = NO;
    panel_.backgroundColor = [NSColor clearColor];
    panel_.hasShadow = NO;
    panel_.ignoresMouseEvents = YES;
    panel_.floatingPanel = YES;
    panel_.hidesOnDeactivate = NO;
    panel_.releasedWhenClosed = NO;
    panel_.level = NSStatusWindowLevel;
    panel_.collectionBehavior =
        NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary |
        NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorIgnoresCycle;
    view_ = [[OverlayView alloc] initWithFrame:panel_.contentView.bounds];
    view_.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    panel_.contentView = view_;
  }

  void show(std::string_view shortcut, std::string_view label, int count) override {
    view_.shortcutText = [NSString stringWithUTF8String:std::string(shortcut).c_str()];
    view_.labelText = [NSString stringWithUTF8String:std::string(label).c_str()];
    view_.count = count;
    [view_ setNeedsDisplay:YES];

    NSDictionary *titleAttributes =
        @{NSFontAttributeName : [NSFont systemFontOfSize:18 weight:NSFontWeightMedium]};
    NSString *title = view_.shortcutText;
    if (count > 1)
      title = [NSString stringWithFormat:@"%@ x%ld", title, (long)count];
    NSSize titleSize = [title sizeWithAttributes:titleAttributes];
    CGFloat width = MAX(150, titleSize.width + 58);
    if (view_.labelText.length > 0) {
      width =
          MAX(width, [view_.labelText
                         sizeWithAttributes:@{NSFontAttributeName : [NSFont systemFontOfSize:12]}]
                             .width +
                         58);
    }
    const CGFloat height = view_.labelText.length > 0 ? 74 : 58;
    NSScreen *screen = [NSScreen mainScreen];
    NSRect visible = screen ? screen.visibleFrame : NSMakeRect(0, 0, 1440, 900);
    CGFloat x = NSMidX(visible) - width / 2;
    CGFloat y = NSMaxY(visible) - height - 28;
    if (settings_.position == OverlayPosition::BottomCenter)
      y = NSMinY(visible) + 28;
    if (settings_.position == OverlayPosition::TopLeft)
      x = NSMinX(visible) + 28;
    if (settings_.position == OverlayPosition::TopRight)
      x = NSMaxX(visible) - width - 28;
    if (settings_.position == OverlayPosition::BottomCenter)
      x = NSMidX(visible) - width / 2;
    NSRect frame = NSMakeRect(x, y, width, height);
    [panel_ setFrame:frame display:YES];
    panel_.alphaValue = 1;
    [panel_ orderFrontRegardless];
    const auto generation = ++generation_;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(settings_.duration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                     if (generation == generation_) {
                       [[panel_ animator] setAlphaValue:0];
                       [panel_ orderOut:nil];
                     }
                   });
  }

  void set_settings(const OverlaySettings &settings) override {
    settings_ = settings;
    NSColor *background = settings_.theme == OverlayTheme::Light ? [NSColor whiteColor]
                          : settings_.theme == OverlayTheme::Graphite
                              ? [NSColor colorWithWhite:0.16 alpha:0.94]
                              : [NSColor blackColor];
    view_.backgroundColor = background;
    view_.darkText = settings_.theme == OverlayTheme::Light;
    [view_ setNeedsDisplay:YES];
  }

 private:
  OatmealPanel *panel_;
  OverlayView *view_;
  OverlaySettings settings_;
  std::size_t generation_ = 0;
};

std::unique_ptr<Overlay> create_overlay() {
  return std::make_unique<MacOverlay>();
}

}  // namespace oatmeal
