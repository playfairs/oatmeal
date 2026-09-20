import AppKit
import SwiftUI

public typealias OatmealSettingsCallback = @convention(c) (Int32, Int32, UnsafePointer<CChar>?) ->
  Void

private struct ShortcutRow: Identifiable {
  let id: Int
  let configKey: String
  var label: String
  var enabled: Bool
}

private final class SettingsViewModel: ObservableObject {
  @Published var shortcuts: [ShortcutRow]
  @Published var theme: Int
  @Published var position: Int
  @Published var duration: Double
  @Published var launchOnLogin: Bool
  @Published var recording = false
  private let callback: OatmealSettingsCallback
  private var monitor: Any?

  init(
    shortcuts: String, theme: Int32, position: Int32, duration: Double, launchOnLogin: Int32,
    callback: @escaping OatmealSettingsCallback
  ) {
    self.shortcuts = shortcuts.split(separator: "\n").enumerated().compactMap { index, line in
      let fields = line.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
      guard fields.count == 3 else { return nil }
      return ShortcutRow(
        id: index, configKey: String(fields[0]), label: String(fields[1]), enabled: fields[2] == "1"
      )
    }
    self.theme = Int(theme)
    self.position = Int(position)
    self.duration = duration
    self.launchOnLogin = launchOnLogin != 0
    self.callback = callback
  }

  deinit {
    if let monitor { NSEvent.removeMonitor(monitor) }
  }

  func toggle(_ index: Int) {
    shortcuts[index].enabled.toggle()
    callback(1, Int32(index), shortcuts[index].enabled ? "1" : "0")
  }

  func updateLabel(_ index: Int, _ label: String) {
    shortcuts[index].label = label
    callback(2, Int32(index), label)
  }

  func remove(_ index: Int) {
    callback(3, Int32(index), nil)
    shortcuts.remove(at: index)
  }

  func setTheme(_ value: Int) {
    theme = value
    callback(4, Int32(value), nil)
  }

  func setPosition(_ value: Int) {
    position = value
    callback(5, Int32(value), nil)
  }

  func setDuration(_ value: Double) {
    duration = value
    callback(6, 0, String(value))
  }

  func save() {
    callback(8, 0, nil)
  }

  func setLaunchOnLogin(_ enabled: Bool) {
    launchOnLogin = enabled
    callback(9, enabled ? 1 : 0, nil)
  }

  func startRecording() {
    guard !recording else { return }
    recording = true
    monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self, self.recording else { return event }
      guard let key = Self.key(for: event) else { return event }
      let configKey = Self.configKey(key: key, flags: event.modifierFlags)
      let label = key.uppercased()
      self.callback(7, 0, configKey)
      self.shortcuts.append(
        ShortcutRow(id: self.shortcuts.count, configKey: configKey, label: label, enabled: true))
      self.recording = false
      if let monitor = self.monitor {
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
      }
      return nil
    }
  }

  private static func configKey(key: String, flags: NSEvent.ModifierFlags) -> String {
    var parts: [String] = []
    if flags.contains(.command) { parts.append("cmd") }
    if flags.contains(.control) { parts.append("ctrl") }
    if flags.contains(.option) { parts.append("option") }
    if flags.contains(.shift) { parts.append("shift") }
    if flags.contains(.function) { parts.append("fn") }
    parts.append(key)
    return parts.joined(separator: "+")
  }

  private static func key(for event: NSEvent) -> String? {
    if let characters = event.charactersIgnoringModifiers, !characters.isEmpty {
      let normalized = characters.lowercased()
      switch normalized {
      case "\u{7f}": return "delete"
      case "\u{1b}": return "escape"
      case "\r", "\n": return "return"
      case "\t": return "tab"
      case " ": return "space"
      default: return normalized
      }
    }

    switch event.keyCode {
    case 126: return "up"
    case 125: return "down"
    case 124: return "right"
    case 123: return "left"
    case 51: return "delete"
    case 53: return "escape"
    case 36: return "return"
    case 48: return "tab"
    default: return nil
    }
  }
}

private struct SettingsView: View {
  @ObservedObject var model: SettingsViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Oatmeal Settings").font(.title2.weight(.semibold))
          Text("Choose the shortcuts Oatmeal confirms.").foregroundStyle(.secondary)
        }
        Spacer()
        Button(model.recording ? "Press a shortcut…" : "Add Shortcut") { model.startRecording() }
          .buttonStyle(.borderedProminent)
          .disabled(model.recording)
      }
      .padding(.bottom, 18)

      List {
        Section("Watched shortcuts") {
          ForEach(Array(model.shortcuts.enumerated()), id: \.element.id) { index, shortcut in
            HStack(spacing: 12) {
              Toggle(isOn: Binding(get: { shortcut.enabled }, set: { _ in model.toggle(index) })) {
                Text(Self.displayName(shortcut.configKey)).font(.body.monospaced())
              }
              .toggleStyle(.checkbox)
              TextField(
                "Label",
                text: Binding(get: { shortcut.label }, set: { model.updateLabel(index, $0) })
              )
              .textFieldStyle(.roundedBorder)
              Button {
                model.remove(index)
              } label: {
                Image(systemName: "trash")
              }
              .buttonStyle(.borderless)
              .help("Remove shortcut")
            }
            .padding(.vertical, 3)
          }
        }

        Section("Overlay") {
          Picker("Theme", selection: Binding(get: { model.theme }, set: { model.setTheme($0) })) {
            Text("Dark").tag(0)
            Text("Light").tag(1)
            Text("Graphite").tag(2)
          }
          Picker(
            "Position", selection: Binding(get: { model.position }, set: { model.setPosition($0) })
          ) {
            Text("Top center").tag(0)
            Text("Bottom center").tag(1)
            Text("Top left").tag(2)
            Text("Top right").tag(3)
          }
          HStack {
            Text("Display duration")
            Slider(
              value: Binding(get: { model.duration }, set: { model.setDuration($0) }), in: 0.25...4)
            Text(String(format: "%.1fs", model.duration)).monospacedDigit().frame(
              width: 42, alignment: .trailing)
          }
        }

        Section("Startup") {
          Toggle(
            "Launch Oatmeal when you log in",
            isOn: Binding(get: { model.launchOnLogin }, set: { model.setLaunchOnLogin($0) }))
          Text("Oatmeal will run quietly in the menu bar after login.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .listStyle(.inset)

      HStack {
        Text("Changes apply immediately.").font(.caption).foregroundStyle(.secondary)
        Spacer()
        Button("Save") { model.save() }.keyboardShortcut(.defaultAction)
      }
      .padding(.top, 14)
    }
    .padding(22)
    .frame(minWidth: 620, minHeight: 500)
  }

  private static func displayName(_ value: String) -> String {
    value.split(separator: "+").map { part in
      switch part.lowercased() {
      case "cmd", "command": return "⌘"
      case "ctrl", "control": return "⌃"
      case "option", "alt": return "⌥"
      case "shift": return "⇧"
      case "fn": return "fn"
      default: return part.uppercased()
      }
    }.joined(separator: " ")
  }
}

private var settingsWindow: NSWindow?
private var settingsModel: SettingsViewModel?

@_cdecl("oatmeal_swift_show_settings")
public func oatmealSwiftShowSettings(
  _ shortcuts: UnsafePointer<CChar>, _ theme: Int32, _ position: Int32, _ duration: Double,
  _ launchOnLogin: Int32, _ callback: OatmealSettingsCallback?
) {
  guard let callback else { return }
  let shortcutPayload = String(cString: shortcuts)
  DispatchQueue.main.async {
    let model = SettingsViewModel(
      shortcuts: shortcutPayload, theme: theme, position: position, duration: duration,
      launchOnLogin: launchOnLogin, callback: callback)
    settingsModel = model
    let controller = NSHostingController(rootView: SettingsView(model: model))
    if settingsWindow == nil {
      settingsWindow = NSWindow(contentViewController: controller)
      settingsWindow?.title = "Oatmeal Settings"
      settingsWindow?.styleMask = [.titled, .closable, .resizable]
      settingsWindow?.isReleasedWhenClosed = false
    } else {
      settingsWindow?.contentViewController = controller
    }
    settingsWindow?.setContentSize(NSSize(width: 680, height: 560))
    settingsWindow?.center()
    settingsWindow?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
