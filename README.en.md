# Snippet Manager

A menu-bar resident snippet & clipboard history manager for macOS. Open a numbered menu via hotkey and auto-paste selected text into the frontmost app. Copied text is recorded automatically with a Clipy-like experience.

**Japanese documentation:** [README.md](README.md)

---

## Features

| Feature | Description |
|---------|-------------|
| Agent app | No Dock icon; lives in the menu bar |
| Clipboard history | Auto-records copied text (up to 100 items, dedup, concealed-copy exclusion) |
| Global hotkeys | Main `⌘⇧V` / History `⌘⌃V` / Snippets `⌘⇧B` (user-configurable) |
| Menu | Numbered `NSMenu` with inline history + folder chunks and numeric shortcuts |
| Auto-paste | Returns focus to the previous app and emulates `⌘V` |
| Snippet editor | Folder tree, drag & drop, auto-save |
| Launch at login | Toggle in Preferences |

## Requirements

- macOS 14.0+
- Xcode 15+ (for building)
- **Accessibility permission** (required for simulated paste)

## Quick Start

### 1. Build & Install

```zsh
cd "Snippet Manager"
xcodebuild -scheme "Snippet Manager" -configuration Release build
cp -R "$(find ~/Library/Developer/Xcode/DerivedData -name 'Snippet Manager.app' -path '*/Release/*' | head -1)" /Applications/
open -a "Snippet Manager"
```

Or open `Snippet Manager.xcodeproj` in Xcode and press **⌘R**.

### 2. First-Time Setup

1. **Accessibility** — System Settings → Privacy & Security → Accessibility → enable `Snippet Manager`
2. **Menu bar** — Look for the paperclip icon (if hidden, hold `Control` and drag the menu bar)
3. **Preferences** — Menu bar → **Preferences…** (⌘,)

### 3. Use History & Snippets

1. Place the cursor in any app
2. Press a hotkey (Main `⌘⇧V` / History `⌘⌃V` / Snippets `⌘⇧B`)
3. Pick a history item or snippet (or press `1`–`9` / `0`)
4. Text is pasted automatically

## Documentation

| Document | Description |
|----------|-------------|
| [User Guide (English)](docs/USER-GUIDE.md) | Operations & troubleshooting |
| [利用ガイド（日本語）](docs/利用ガイド.md) | Japanese user guide |
| [Detailed Design (English)](docs/DESIGN.md) | Architecture & data flow |
| [詳細設計書（日本語）](docs/設計書.md) | Japanese design document |
| [Developer Setup](docs/SETUP.md) | Dependencies & project layout |

## Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) 3.x — global hotkeys and user preferences

## License

This project is released under the [MIT License](LICENSE).

- Third-party license notices: see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)
- The clipboard history feature is *behaviorally inspired* by [Clipy](https://github.com/Clipy/Clipy) (MIT License), but **no Clipy source code, icons, or other assets are included**. This project is not affiliated with the Clipy project.

## Repository

https://github.com/se-like/Snipet-Manager
