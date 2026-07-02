//
//  AppDelegate.swift
//  Snippet Manager
//

import AppKit
import Combine
import KeyboardShortcuts

/// 常駐型エージェントのライフサイクル・ホットキー・ペースト連携を司る
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem?
  private var cancellables: Set<AnyCancellable> = []

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)

    migrateConflictingShortcutsIfNeeded()
    setupStatusItem()
    setupHotkeys()
    setupMenuCallbacks()
    observeStoreChanges()
    ClipboardHistoryStore.shared.startMonitoring()
    PasteController.requestAccessibilityIfNeeded()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    false
  }

  // MARK: - Setup

  /// 旧バージョンでスニペットメニューに Cmd+Shift+V を明示登録済みの場合、
  /// メインメニューのデフォルトと二重発火するためスニペット側をデフォルト（Cmd+Shift+B）へ戻す
  private func migrateConflictingShortcutsIfNeeded() {
    if let snippetShortcut = KeyboardShortcuts.getShortcut(for: .showSnippetPicker),
       snippetShortcut == KeyboardShortcuts.getShortcut(for: .showMainMenu)
    {
      KeyboardShortcuts.reset(.showSnippetPicker)
    }
  }

  /// メニューバー（履歴 + スニペット階層 + 編集 + 環境設定 + 終了）
  private func setupStatusItem() {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem = item

    if let button = item.button {
      let image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "Snippet Manager")
      image?.isTemplate = true
      button.image = image
      button.toolTip = "Snippet Manager"
    }

    rebuildStatusMenu()
  }

  private func observeStoreChanges() {
    SnippetStore.shared.$folders
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.rebuildStatusMenu()
      }
      .store(in: &cancellables)

    ClipboardHistoryStore.shared.$items
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.rebuildStatusMenu()
      }
      .store(in: &cancellables)

    // インライン件数・フォルダ分割数の変更をステータスメニューへ即反映
    ClipboardHistoryStore.shared.$inlineItemCount
      .combineLatest(ClipboardHistoryStore.shared.$itemsPerFolder)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _, _ in
        self?.rebuildStatusMenu()
      }
      .store(in: &cancellables)
  }

  private func rebuildStatusMenu() {
    let menu = NSMenu()

    let hasHistory = !ClipboardHistoryStore.shared.items.isEmpty
    if hasHistory {
      MenuController.shared.appendHistoryItems(to: menu, includeSectionHeader: true)
      menu.addItem(.separator())
    }

    MenuController.shared.appendSnippetItems(to: menu, separateMenu: false)
    if menu.items.last?.isSeparatorItem == false {
      menu.addItem(.separator())
    }

    if hasHistory {
      menu.addItem(makeMenuItem(title: "履歴を消去", action: #selector(clearHistory), keyEquivalent: ""))
    }
    menu.addItem(makeMenuItem(title: "スニペットを編集", action: #selector(openEditor), keyEquivalent: "e"))
    menu.addItem(makeMenuItem(title: "環境設定…", action: #selector(openPreferences), keyEquivalent: ","))
    menu.addItem(.separator())
    menu.addItem(makeMenuItem(title: "Snippet Manager を終了", action: #selector(quitApp), keyEquivalent: "q"))
    statusItem?.menu = menu
  }

  private func makeMenuItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    item.target = self
    return item
  }

  private func setupHotkeys() {
    KeyboardShortcuts.onKeyUp(for: .showMainMenu) {
      MenuController.shared.popUpMainMenu()
    }
    KeyboardShortcuts.onKeyUp(for: .showHistoryMenu) {
      MenuController.shared.popUpHistoryMenu()
    }
    KeyboardShortcuts.onKeyUp(for: .showSnippetPicker) {
      MenuController.shared.popUpSnippetMenu()
    }
  }

  private func setupMenuCallbacks() {
    MenuController.shared.onSelect = { [weak self] snippet in
      self?.paste(text: snippet.content)
    }
    MenuController.shared.onSelectHistory = { [weak self] clip in
      self?.paste(text: clip.content)
    }
  }

  // MARK: - Actions

  private func paste(text: String) {
    let previousApp = MenuController.shared.previousApplication()
    PasteController.paste(text: text, returningFocusTo: previousApp)
  }

  @objc private func clearHistory() {
    let alert = NSAlert()
    alert.messageText = "クリップボード履歴をすべて消去しますか？"
    alert.informativeText = "この操作は取り消せません。"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "消去")
    alert.addButton(withTitle: "キャンセル")

    NSApp.activate()
    if alert.runModal() == .alertFirstButtonReturn {
      ClipboardHistoryStore.shared.clearHistory()
    }
  }

  @objc private func openEditor() {
    PreferencesWindowController.shared.show(tab: .snippets)
  }

  @objc private func openPreferences() {
    PreferencesWindowController.shared.show(tab: .general)
  }

  @objc private func quitApp() {
    NSApp.terminate(nil)
  }
}
