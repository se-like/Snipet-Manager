# Snippet Manager User Guide

Audience: end users (developers see [SETUP.md](SETUP.md))

---

## 1. Overview

Snippet Manager runs in the **menu bar** and lets you paste saved text snippets into any app via a global hotkey.

- No Dock icon
- Access via the **paperclip** icon in the menu bar

---

## 2. First-Time Setup

### 2.1 Install

Follow [README.en.md](../README.en.md) to place `Snippet Manager.app` in `/Applications/`, then launch it.

### 2.2 Required: Accessibility

Auto-paste requires **Accessibility** permission.

1. System Settings → **Privacy & Security** → **Accessibility**
2. Enable **Snippet Manager**

Without this, text is copied to the clipboard but **⌘V is not simulated**.

### 2.3 Launch at Login (Optional)

1. Menu bar → **Preferences…** (⌘,)
2. **General** tab → enable **Launch at login**
3. If prompted, use **Open Login Items** to approve in System Settings

---

## 3. Invoking Snippets

### 3.1 Hotkey

| Action | Default |
|--------|---------|
| Open snippet menu | `⌘⇧V` |

To change: **Preferences → Shortcuts** and record a new key.

### 3.2 Menu Usage

1. Place the cursor in the target app
2. Press the hotkey — menu appears at the **mouse cursor**
3. Click a folder to open its submenu
4. Click a snippet or use number keys

| Key | Action (inside submenu) |
|-----|-------------------------|
| `1`–`9` | Snippets 1–9 |
| `0` | 10th snippet |
| `Esc` | Close menu |

The same hierarchy is available from the menu bar icon.

---

## 4. Managing Snippets

Open **Preferences → Snippets** or **Edit Snippets** (⌘E) from the menu.

### 4.1 Layout

- **Left:** folder/snippet tree (`NSOutlineView`)
- **Right:** editor pane (folder name or snippet title/body)
- **Toolbar:** add folder, add snippet, delete

### 4.2 Folders

| Action | Steps |
|--------|-------|
| Create | **Add Folder** → edit name in the right pane |
| Rename | Select folder → edit **Folder name** on the right |
| Delete | Select folder → **Delete** or Delete key (removes contained snippets) |

### 4.3 Snippets

| Action | Steps |
|--------|-------|
| Add | Select folder → **Add Snippet** or **⌘N** |
| Edit | Select snippet → edit title/body (auto-saved) |
| Move to folder | **Drag & drop** snippet onto another folder |
| Reorder | Drop between rows within the same folder |
| Delete | Select snippet → **Delete** or Delete key |

Changes are saved immediately to UserDefaults.

---

## 5. Menu Bar Reference

| Item | Shortcut | Description |
|------|------------|-------------|
| Snippets (tree) | — | Folder hierarchy |
| Edit Snippets | ⌘E | Snippets tab in Preferences |
| Preferences… | ⌘, | General, Shortcuts, Snippets |
| Quit Snippet Manager | ⌘Q | Exit app |

---

## 6. Troubleshooting

### No menu bar icon

- Check if running: `pgrep -x "Snippet Manager"`
- Menu bar full? Hold `Control` and drag the left edge of the menu bar
- Restart: `pkill -x "Snippet Manager"; open -a "Snippet Manager"`

### Hotkey not working

- Check **Preferences → Shortcuts**
- Conflicts with other apps?
- May need **Input Monitoring** in Privacy & Security

### Paste not working

- Verify **Accessibility** (§2.2)
- Target app must accept paste

### Folder seems useless after creation

- Ensure the new folder is **selected** in the left tree
- Edit its name on the right
- Add snippets with **⌘N** or drag from another folder

---

## 7. Feature Scope

This app focuses on **snippet management** only. Not included:

- Clipboard history
- Snippet import / export
- Per-folder global hotkeys

---

## 8. Related Docs

- [Detailed Design](DESIGN.md)
- [README.en.md](../README.en.md)
