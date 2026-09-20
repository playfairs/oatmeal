# Oatmeal REWLSSS (so follow them ok?)

These rules apply to gawwwhhhhkk and him only UHHHHHHHHGGHHHHHHHH (im so fucking sorry)

---

## Platform separation

i gave Oatmeal some independent platform implementations:

```text
src/platform/macos/
src/platform/windows/
```

they are sibling implementations. neither platform may depend on the other.
A macOS change must not import Windows implementation details, and a Windows
change must not import macOS implementation details.

The intended dependency direction is:

```text
core <- application <- platform/macos
                       platform/windows
```

A platform implementation should be replaceable without rewriting the other
platform implementation.

## Universal code

The following directories should be and are platform-neutral:

```text
src/core/
src/application/
```

Universal code must not contain AppKit, Foundation, Objective-C++, Swift,
Win32, Windows Specific APIs, or Windows UI APIs. Shared behavior belongs in a
neutral core algorithm or application contract. Platform behavior belongs in
the corresponding platform directory.

The universal shortcut, aggregation, and configuration implementations remain
the source of truth. Platform backends translate native input into the shared
Oatmeal representation; they must not duplicate those algorithms.

## Platform code

Operating-system-specific behavior belongs inside its platform directory:

```text
src/platform/macos/
src/platform/windows/
```

The macOS implementation remains Objective-C++, Swift, AppKit, Foundation,
Core Graphics, and other native macOS APIs where appropriate. It must not
depend on anything under `src/platform/windows/`.

The Windows implementation is written in C#. Its backend may contain
Windows-specific initialization, lifecycle, input translation, and native API
adapters while keeping universal behavior in `src/core/` and
`src/application/`.

## Windows UI

the windows ui is urs to mess with but heres this just as influence

> the Windows gui must be implemented using native windows ui shit in C#.
> external or cross-platform ui frameworks is not preferred.

The following must not be introduced:

```text
Electron
Tauri
Avalonia
GTK
Uno Platform
MAUI
web UI
embedded browser UI

Qt, but if it looks good with qt go for it
```

The exact native Windows UI technology may be selected when Windows UI work
begins. Do not prematurely implement that choice.

The windows ui is intentionally not implemented in this task... The current
Windows foundation just preps independent lc and input boundaries so a
you GAWHHHHHKKK can add native ui without restructuring the backend.
There is currently no Windows overlay, overlay rendering, settings window,
settings control, menu/tray UI, animation, styling, theme, layout, or UI
component implementation.

## No cross-platform ~~contamination~~

Do not add the Windows implementation to the macOS directory because it is
convenient. Do not add a macOS conditional to the Windows backend. Do not move
a platform-specific class into `core/` or `application/` merely because both
platforms need related behavior.

Instead, put genuinely shared behavior in the appropriate neutral abstraction
and platform behavior in the corresponding platform implementation.

Changes must remain isolated: macOS and Windows should evolve independently
while sharing only genuinely platform-neutral application and core contracts.

## Build notes

The macOS executable remains the existing Objective-C++/Swift Nox target. The
Windows backend is a standalone C# project at
`src/platform/windows/Oatmeal.Windows.csproj`; it is intentionally not added
to the macOS source list or made part of the macOS build. Build it with the
.NET 11 SDK in a Windows development environment. No cross-compilation setup is
provided or required for this backend foundation.

additionally if u want to use nox as the build system, download it from 
https://github.com/playfairs/nox/releases/latest