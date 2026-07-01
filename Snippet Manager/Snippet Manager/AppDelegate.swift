//
//  AppDelegate.swift
//  Snippet Manager
//

import AppKit
import Combine
import KeyboardShortcuts

/// 常駐型エージェントのライフサイクル・ホットキー・ペースト連携を司る
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem?
  private var storeCancellable: AnyCancellable?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)

    setupStatusItem()
    setupHotkey()
    setupSnippetMenu()
    observeStoreChanges()
    PasteController.requestAccessibilityIfNeeded()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    false
  }

  // MARK: - Setup

  /// メニューバー（スニペット階層 + 編集 + 環境設定 + 終了）
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
    storeCancellable = SnippetStore.shared.$folders
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.rebuildStatusMenu()
      }
  }

  private func rebuildStatusMenu() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let menu = NSMenu()
      SnippetMenuController.shared.appendSnippetItems(to: menu, separateMenu: false)
      menu.addItem(.separator())
      menu.addItem(self.makeMenuItem(title: "スニペットを編集", action: #selector(self.openEditor), keyEquivalent: "e"))
      menu.addItem(self.makeMenuItem(title: "環境設定…", action: #selector(self.openPreferences), keyEquivalent: ","))
      menu.addItem(.separator())
      menu.addItem(self.makeMenuItem(title: "Snippet Manager を終了", action: #selector(self.quitApp), keyEquivalent: "q"))
      self.statusItem?.menu = menu
    }
  }

  private func makeMenuItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    item.target = self
    return item
  }

  private func setupHotkey() {
    KeyboardShortcuts.onKeyUp(for: .showSnippetPicker) { [weak self] in
      self?.showSnippetPicker()
    }
  }

  private func setupSnippetMenu() {
    DispatchQueue.main.async {
      SnippetMenuController.shared.onSelect = { [weak self] snippet in
        self?.paste(snippet: snippet)
      }
    }
  }

  // MARK: - Actions

  @objc private func showSnippetPicker() {
    DispatchQueue.main.async {
      SnippetMenuController.shared.popUpSnippetMenu()
    }
  }

  private func paste(snippet: Snippet) {
    let previousApp = SnippetMenuController.shared.previousApplication()
    PasteController.paste(text: snippet.content, returningFocusTo: previousApp)
  }

  @objc private func openEditor() {
    DispatchQueue.main.async {
      PreferencesWindowController.shared.show(tab: .snippets)
    }
  }

  @objc private func openPreferences() {
    DispatchQueue.main.async {
      PreferencesWindowController.shared.show(tab: .general)
    }
  }

  @objc private func quitApp() {
    NSApp.terminate(nil)
  }
}
