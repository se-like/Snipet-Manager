# Snippet Manager — Detailed Design

| Field | Value |
|-------|-------|
| Document version | 1.0 |
| App version | 1.0 (MARKETING_VERSION) |
| Last updated | 2026-07-01 |
| Target OS | macOS 14.0+ |

**Japanese:** [設計書.md](設計書.md)

---

## 1. Purpose & Scope

### 1.1 Purpose

Provide a menu-bar resident macOS app that invokes user-defined text snippets via a **global hotkey** and **auto-pastes** into the frontmost application.

### 1.2 In Scope

- Menu bar agent (`LSUIElement`)
- User-configurable global hotkey
- Numbered `NSMenu` snippet picker
- Folder hierarchy with snippet CRUD
- Drag & drop move/reorder
- Launch at login
- UserDefaults persistence

### 1.3 Out of Scope

- Clipboard history
- iCloud / file sync
- Import/export
- Windows / iOS

---

## 2. System Architecture

### 2.1 Overview

```mermaid
flowchart TB
  subgraph UI
    MB[MenuBar / NSStatusItem]
    PREF[Preferences Window]
    MENU[Snippet NSMenu Popup]
  end

  subgraph Core
    AD[AppDelegate]
    SMC[SnippetMenuController]
    STORE[SnippetStore]
    PC[PasteController]
    LAL[LaunchAtLoginManager]
  end

  subgraph External
    KS[KeyboardShortcuts SPM]
    UD[UserDefaults]
    AX[Accessibility / CGEvent]
  end

  MB --> AD
  AD --> SMC
  AD --> KS
  SMC --> MENU
  SMC --> STORE
  AD --> PC
  PREF --> STORE
  PREF --> LAL
  PREF --> KS
  STORE --> UD
  PC --> AX
```

### 2.2 Technology Stack

| Layer | Technology |
|-------|------------|
| UI | SwiftUI + AppKit (NSOutlineView, NSMenu) |
| Language | Swift 5 |
| Minimum OS | macOS 14.0 |
| Persistence | UserDefaults (JSON) |
| Hotkeys | KeyboardShortcuts 3.0.1 |
| Login item | ServiceManagement.SMAppService |
| Paste | NSPasteboard + CGEvent |

### 2.3 Project Layout

See [SETUP.md](SETUP.md) for the full file list.

---

## 3. Functional Design

### 3.1 Agent Mode

| Setting | Value |
|---------|-------|
| `INFOPLIST_KEY_LSUIElement` | YES |
| `NSApp.setActivationPolicy` | `.accessory` |
| Dock icon | Hidden |
| Quit | Menu bar only (⌘Q) |

### 3.2 Global Hotkey

- **Identifier:** `showSnippetPicker`
- **Default:** `Cmd + Shift + V`
- **Persistence:** KeyboardShortcuts → UserDefaults
- **UI:** `KeyboardShortcuts.Recorder` in Preferences → Shortcuts
- **Handler:** `KeyboardShortcuts.onKeyUp(for: .showSnippetPicker)`

### 3.3 Snippet Menu

Built dynamically by `SnippetMenuController`.

```
Snippets            (disabled header)
├─ Folder A  ▶
│   ├─ 1. Title A   (key 1)
│   └─ 2. Title B   (key 2)
└─ Folder B  ▶
    └─ 3. Title C
```

| Spec | Value |
|------|-------|
| Position | `NSEvent.mouseLocation` |
| Numbering | `{n}. {title}` (global across folders) |
| Numeric keys | 1–9, 0 inside submenu |
| Tooltip | Snippet body |
| Title max | 50 chars + `…` |

### 3.4 Auto-Paste Pipeline

`PasteController.paste` executes in order:

1. Write string to `NSPasteboard.general`
2. Activate previously frontmost app
3. Wait 0.1 seconds
4. Post `Cmd+V` via `CGEvent` (virtualKey 9, `.maskCommand`)

Requires Accessibility trust (`AXIsProcessTrusted()`).

### 3.5 Snippet Editor

| Component | Responsibility |
|-----------|----------------|
| `SnippetEditorView` | Toolbar, split layout, editor pane |
| `SnippetOutlineView` | NSOutlineView, selection, drag & drop |
| `SnippetStore` | CRUD, move, persist |

**Selection model:** `.folder(UUID)` | `.snippet(folderID, snippetID)`

**Drag & drop pasteboard:** `snippetUUID|sourceFolderUUID`

### 3.6 Preferences

Sidebar via `NavigationSplitView`:

| Tab | Content |
|-----|---------|
| General | Launch at login |
| Shortcuts | Hotkey recorder |
| Snippets | Embedded editor |

---

## 4. Data Model

### 4.1 Snippet

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| title | String | Display name |
| content | String | Pasted text |

### 4.2 SnippetFolder

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| title | String | Folder name |
| index | Int | Sort order |
| snippets | [Snippet] | Children |

### 4.3 Persistence

| Key | Content |
|-----|---------|
| `snippetFolders` | JSON array of folders |
| `snippets` | Legacy flat list (migrated on first load) |

---

## 5. Non-Functional Requirements

| Topic | Detail |
|-------|--------|
| Sandbox | Disabled (CGEvent requirement) |
| Hardened Runtime | Enabled |
| Permissions | Accessibility; Input Monitoring if needed |
| Scale | Hundreds of snippets via UserDefaults |

---

## 6. Known Limitations

1. `CGEvent` paste uses US virtual key code 9 for `V`
2. No clipboard history or per-folder hotkeys
3. Numeric keys work **after** opening a folder submenu
4. UserDefaults not suited for very large datasets

---

## 7. Revision History

| Ver | Date | Notes |
|-----|------|-------|
| 1.0 | 2026-07-01 | Initial release |

---

## Appendix: PDF Export

HTML version: [DESIGN.html](DESIGN.html)

Open in a browser and use **File → Export as PDF**.
