# Snippet Manager User Guide

Audience: end users (developers see [SETUP.md](SETUP.md))

---

## 1. Overview

Snippet Manager runs in the **menu bar** and lets you paste saved text snippets and **clipboard history** into any app via global hotkeys.

- No Dock icon
- Access via the **paperclip** icon in the menu bar
- Copied text is recorded automatically (Clipy-like experience)

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

## 3. Invoking History & Snippets

### 3.1 Hotkeys

| Action | Default | Contents |
|--------|---------|----------|
| Open main menu | `⌘⇧V` | Clipboard history + snippets |
| Open history menu | `⌘⌃V` | Clipboard history only |
| Open snippet menu | `⌘⇧B` | Snippets only |

To change: **Preferences → Shortcuts** and record a new key.

### 3.2 Menu Usage

1. Place the cursor in the target app
2. Press a hotkey — menu appears at the **mouse cursor**
3. History items are numbered, newest first; click a folder for its submenu
4. Click an item or use number keys — it is pasted automatically

| Key | Action |
|-----|--------|
| `1`–`9` | Items 1–9 |
| `0` | 10th item |
| `Esc` | Close menu |

The same content (history + snippet hierarchy) is available from the menu bar icon.

### 3.3 About Clipboard History

- Text copied with **⌘C in any app is recorded automatically** (default: up to 30 items)
- The latest 10 items appear inline; older ones are grouped into folders like "11 - 20"
- Re-copying identical text moves it to the top (no duplicates)
- Copies marked as concealed (e.g. by password managers) are never recorded
- History persists across app restarts
- Tune the counts in **Preferences → History** (§5.1)

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
| History (numbered) | — | Clipboard history, newest first |
| Snippets (tree) | — | Folder hierarchy |
| Clear History | — | Delete all history (with confirmation) |
| Edit Snippets | ⌘E | Snippets tab in Preferences |
| Preferences… | ⌘, | General, Shortcuts, History, Snippets |
| Quit Snippet Manager | ⌘Q | Exit app |

### 5.1 Preferences → History Tab

| Setting | Default | Range |
|---------|---------|-------|
| Max history size | 30 | 1–100 |
| Inline items in menu | 10 | 0–20 |
| Items per folder | 10 | 1–20 |

The "Clear History…" button deletes all history (with a confirmation dialog).

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

Not included:

- Images / rich text / files in clipboard history (text only)
- Snippet import / export
- Per-folder global hotkeys

---

## 8. Related Docs

- [Detailed Design](DESIGN.md)
- [README.en.md](../README.en.md)
