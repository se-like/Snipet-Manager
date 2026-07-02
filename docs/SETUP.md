# Developer Setup

**日本語:** 本ドキュメントは開発者向けです。利用者向けは [利用ガイド.md](利用ガイド.md) を参照。

---

## Requirements

| Tool | Version |
|------|---------|
| macOS | 14.0+ (deployment target) |
| Xcode | 15+ recommended |
| Swift | 5 |
| Apple Developer | Code signing team configured in project |

## Clone & Open

```zsh
git clone https://github.com/se-like/Snipet-Manager.git
cd Snipet-Manager/Snippet\ Manager
open Snippet\ Manager.xcodeproj
```

## Dependencies (SPM)

Resolved in `Snippet Manager.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`:

| Package | Version | Purpose |
|---------|---------|---------|
| [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | 3.0.1 | Global hotkeys + user preference recorder |

Xcode resolves packages automatically on first open.

## Build

```zsh
# Debug
xcodebuild -scheme "Snippet Manager" -configuration Debug build

# Release
xcodebuild -scheme "Snippet Manager" -configuration Release build
```

Output: `~/Library/Developer/Xcode/DerivedData/Snippet_Manager-*/Build/Products/*/Snippet Manager.app`

## Project Settings (Important)

| Setting | Value | Reason |
|---------|-------|--------|
| `PRODUCT_BUNDLE_IDENTIFIER` | `jp.co.crowdcloud.Snippet-Manager` | App ID |
| `INFOPLIST_KEY_LSUIElement` | YES | Menu bar agent |
| `ENABLE_APP_SANDBOX` | NO | CGEvent paste |
| `MACOSX_DEPLOYMENT_TARGET` | 14.0 | Minimum OS |
| `INFOPLIST_KEY_NSAccessibilityUsageDescription` | Set | Paste permission prompt |

## Source File Map

| File | Role |
|------|------|
| `Snippet_ManagerApp.swift` | App entry, `Settings` scene |
| `AppDelegate.swift` | Lifecycle, status item, hotkey wiring |
| `SnippetStore.swift` | Snippet persistence & business logic |
| `ClipItem.swift` | Clipboard history item model |
| `ClipboardHistoryStore.swift` | Pasteboard polling, history retention & persistence |
| `MenuController.swift` | NSMenu popup (history + snippets) |
| `SnippetOutlineView.swift` | Editor outline + D&D |
| `SnippetEditorView.swift` | Editor UI shell |
| `PreferencesView.swift` | Preferences tabs |
| `PasteController.swift` | Pasteboard + CGEvent |
| `LaunchAtLoginManager.swift` | SMAppService wrapper |

## Testing Checklist (Manual)

1. Menu bar icon visible after launch
2. Hotkeys open menus at cursor (Main `⌘⇧V` / History `⌘⌃V` / Snippets `⌘⇧B`)
3. Snippet selection pastes into TextEdit
4. Copying text in any app adds it to history within ~1 s (top of the list)
5. Re-copying identical text moves it to the top without duplication
6. History persists across app restart (`~/Library/Application Support/Snippet Manager/clipboard-history.json`)
7. Clear History (status menu / Preferences → History) empties the list after confirmation
8. Accessibility denied → paste simulation fails (check Console)
9. Preferences: launch at login toggle; history size/inline/folder steppers reflected in menus
10. Editor: folder create/select/rename, snippet D&D between folders
11. Menu rebuilds after store changes

## Documentation Index

| Doc | Language |
|-----|----------|
| [README.md](../README.md) | JA |
| [README.en.md](../README.en.md) | EN |
| [設計書.md](設計書.md) | JA design |
| [DESIGN.md](DESIGN.md) | EN design |
| [利用ガイド.md](利用ガイド.md) | JA user |
| [USER-GUIDE.md](USER-GUIDE.md) | EN user |

## UI/UX Review Rule

See `.cursor/rules/ui-ux-review.mdc` for mandatory UX checklist on UI changes.
