# Oatmeal

Oatmeal is a tiny native macOS utility that confirms selected keyboard shortcuts with a quiet overlay.

## Why

Copying has almost no visible feedback. For people with OCD, or anyone caught in a checking loop, that can mean pressing `⌘C` or `Ctrl+C` repeatedly just to feel sure it worked. Oatmeal shows a small confirmation without intercepting the shortcut, so the copy still reaches the application normally.

Oatmeal is a usability aid, not medical treatment. Its purpose is simply to make an otherwise invisible action visible. Making you feel certain :D

## Use

CURRENT Requirements: macOS, Apple Command Line Tools, Nix, and Nox. (Plans to add support for Windows and Linux are coming soon dw)

```sh
nix develop
nox setup
nox compile
nox test
./build/debug/oatmeal/oatmeal
```

Oatmeal runs in the menu bar. Open **Settings** to enable or disable shortcuts, change labels, record new combinations, and adjust the overlay theme, position, and duration.

The default shortcuts are:

- `⌘C` — Clicked
- `⌘V` — Pasted
- `⌘Z` — Undo

Settings are stored in `~/Library/Application Support/Oatmeal/`.

## Permissions

macOS requires Accessibility or Input Monitoring permission for global shortcut observation. Oatmeal uses a listen-only monitor: it observes configured shortcuts without replacing or blocking them.