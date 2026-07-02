//
//  MenuController.swift
//  Snippet Manager
//

import AppKit

/// 番号付き NSMenu ポップアップ（クリップボード履歴 + スニペット階層）
///
/// Clipy と同等の3系統メニューを提供する:
/// - メイン: 履歴 + スニペット
/// - 履歴のみ
/// - スニペットのみ
@MainActor
final class MenuController: NSObject {
  static let shared = MenuController()

  private let maxKeyEquivalents = 10
  private let maxTitleLength = 50
  private let shortenSymbol = "…"
  private let snippetIcon: NSImage = {
    let image = NSImage(systemSymbolName: "doc.plaintext", accessibilityDescription: "スニペット")!
    image.isTemplate = true
    image.size = NSSize(width: 12, height: 13)
    return image
  }()
  private let folderIcon: NSImage = {
    let image = NSImage(systemSymbolName: "folder", accessibilityDescription: "フォルダ")!
    image.isTemplate = true
    image.size = NSSize(width: 15, height: 13)
    return image
  }()
  private let historyIcon: NSImage = {
    let image = NSImage(systemSymbolName: "clock", accessibilityDescription: "履歴")!
    image.isTemplate = true
    image.size = NSSize(width: 13, height: 13)
    return image
  }()

  private var previousApp: NSRunningApplication?
  var onSelect: ((Snippet) -> Void)?
  var onSelectHistory: ((ClipItem) -> Void)?

  private override init() {
    super.init()
  }

  func previousApplication() -> NSRunningApplication? {
    previousApp
  }

  // MARK: - Popup

  /// メインメニュー（履歴 + スニペット）をマウス位置に表示
  func popUpMainMenu() {
    rememberFrontmostApp()
    let menu = NSMenu(title: "Snippet Manager")
    appendHistoryItems(to: menu, includeSectionHeader: true)
    if !menu.items.isEmpty, !SnippetStore.shared.folders.isEmpty {
      menu.addItem(.separator())
    }
    appendSnippetItems(to: menu, separateMenu: false)
    if menu.items.isEmpty {
      menu.addItem(makeEmptyPlaceholderItem(title: "履歴・スニペットはありません"))
    }
    popUp(menu)
  }

  /// クリップボード履歴メニューをマウス位置に表示
  func popUpHistoryMenu() {
    rememberFrontmostApp()
    let menu = NSMenu(title: "履歴")
    appendHistoryItems(to: menu, includeSectionHeader: true)
    if menu.items.isEmpty {
      menu.addItem(makeEmptyPlaceholderItem(title: "履歴はありません"))
    }
    popUp(menu)
  }

  /// スニペットメニューをマウス位置に表示
  func popUpSnippetMenu() {
    rememberFrontmostApp()
    let menu = NSMenu(title: "スニペット")
    appendSnippetItems(to: menu, separateMenu: false)
    if menu.items.isEmpty {
      menu.addItem(makeEmptyPlaceholderItem(title: "スニペットはありません"))
    }
    popUp(menu)
  }

  private func makeEmptyPlaceholderItem(title: String) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    item.isEnabled = false
    return item
  }

  private func popUp(_ menu: NSMenu) {
    menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
  }

  // MARK: - History Menu Building

  /// クリップボード履歴をメニューへ追加
  ///
  /// Clipy 同等: 先頭 N 件をインライン表示し、超過分は「11 - 20」のような
  /// サブフォルダにまとめる。番号は全体で連番、数値キーはインライン先頭10件のみ。
  func appendHistoryItems(to menu: NSMenu, includeSectionHeader: Bool) {
    let store = ClipboardHistoryStore.shared
    let items = store.items
    guard !items.isEmpty else { return }

    if includeSectionHeader {
      let header = NSMenuItem(title: "履歴", action: nil, keyEquivalent: "")
      header.isEnabled = false
      menu.addItem(header)
    }

    let inlineCount = min(store.inlineItemCount, items.count)

    for index in 0..<inlineCount {
      menu.addItem(makeHistoryMenuItem(items[index], listNumber: index + 1, assignKeyEquivalent: true))
    }

    // インライン超過分をフォルダへ分割
    var folderStart = inlineCount
    while folderStart < items.count {
      let folderEnd = min(folderStart + store.itemsPerFolder, items.count)
      let folderItem = NSMenuItem(
        title: "\(folderStart + 1) - \(folderEnd)",
        action: nil,
        keyEquivalent: ""
      )
      folderItem.image = folderIcon

      let subMenu = NSMenu(title: folderItem.title)
      for index in folderStart..<folderEnd {
        subMenu.addItem(makeHistoryMenuItem(items[index], listNumber: index + 1, assignKeyEquivalent: false))
      }
      folderItem.submenu = subMenu
      menu.addItem(folderItem)

      folderStart = folderEnd
    }
  }

  private func makeHistoryMenuItem(_ clip: ClipItem, listNumber: Int, assignKeyEquivalent: Bool) -> NSMenuItem {
    let title = trimmedTitle(menuTitle(for: clip.content))
    let markedTitle = "\(listNumber). \(title)"

    var keyEquivalent = ""
    if assignKeyEquivalent, listNumber <= maxKeyEquivalents {
      keyEquivalent = "\(listNumber % 10)"
    }

    let item = NSMenuItem(
      title: markedTitle,
      action: #selector(selectHistoryItem(_:)),
      keyEquivalent: keyEquivalent
    )
    // 修飾キーなしの数値キーで選択できるようにする（Clipy と同じ）
    item.keyEquivalentModifierMask = []
    item.target = self
    item.representedObject = clip.id
    item.toolTip = tooltip(for: clip.content)
    item.image = historyIcon
    return item
  }

  /// 複数行テキストは先頭の非空行をメニュータイトルに使う
  /// 巨大なコピー内容でもメニュー構築が重くならないよう先頭部分のみ走査する
  private func menuTitle(for content: String) -> String {
    let scanWindow = String(content.prefix(500))
    let firstLine = scanWindow
      .components(separatedBy: .newlines)
      .first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    return firstLine?.trimmingCharacters(in: .whitespaces)
      ?? scanWindow.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func tooltip(for content: String) -> String {
    let maxLength = 500
    guard let end = content.index(content.startIndex, offsetBy: maxLength, limitedBy: content.endIndex),
          end < content.endIndex
    else { return content }
    return String(content[..<end]) + shortenSymbol
  }

  @objc private func selectHistoryItem(_ sender: NSMenuItem) {
    guard let id = sender.representedObject as? UUID,
          let clip = ClipboardHistoryStore.shared.item(id: id)
    else { return }
    onSelectHistory?(clip)
  }

  // MARK: - Snippet Menu Building

  /// メニューバー用: スニペット階層をメニューへ追加
  func appendSnippetItems(to menu: NSMenu, separateMenu: Bool) {
    guard !SnippetStore.shared.folders.isEmpty else { return }

    if separateMenu {
      menu.addItem(.separator())
    }

    let header = NSMenuItem(title: "スニペット", action: nil, keyEquivalent: "")
    header.isEnabled = false
    menu.addItem(header)

    appendFolderItems(to: menu, startListNumber: 1)
  }

  private func appendFolderItems(to menu: NSMenu, startListNumber: Int) {
    var listNumber = startListNumber
    let sortedFolders = SnippetStore.shared.folders.sorted { $0.index < $1.index }

    for folder in sortedFolders {
      let folderItem = NSMenuItem(title: folder.title, action: nil, keyEquivalent: "")
      folderItem.image = folderIcon
      menu.addItem(folderItem)

      let subMenu = NSMenu(title: folder.title)
      folderItem.submenu = subMenu

      for (snippetIndex, snippet) in folder.snippets.enumerated() {
        let item = makeSnippetMenuItem(
          snippet,
          listNumber: listNumber,
          submenuIndex: snippetIndex
        )
        subMenu.addItem(item)
        listNumber += 1
      }
    }
  }

  private func makeSnippetMenuItem(_ snippet: Snippet, listNumber: Int, submenuIndex: Int) -> NSMenuItem {
    let title = trimmedTitle(snippet.title)
    let markedTitle = "\(listNumber). \(title)"

    var keyEquivalent = ""
    if submenuIndex < maxKeyEquivalents {
      let shortcutNumber = (submenuIndex == maxKeyEquivalents - 1) ? 0 : submenuIndex + 1
      keyEquivalent = "\(shortcutNumber)"
    }

    let item = NSMenuItem(
      title: markedTitle,
      action: #selector(selectSnippet(_:)),
      keyEquivalent: keyEquivalent
    )
    // 修飾キーなしの数値キーで選択できるようにする（Clipy と同じ）
    item.keyEquivalentModifierMask = []
    item.target = self
    item.representedObject = snippet.id
    item.toolTip = snippet.content
    item.image = snippetIcon
    return item
  }

  private func trimmedTitle(_ title: String) -> String {
    guard title.count > maxTitleLength else { return title }
    let index = title.index(title.startIndex, offsetBy: maxTitleLength)
    return String(title[..<index]) + shortenSymbol
  }

  private func rememberFrontmostApp() {
    let frontmost = NSWorkspace.shared.frontmostApplication
    if frontmost?.bundleIdentifier == Bundle.main.bundleIdentifier {
      previousApp = nil
    } else {
      previousApp = frontmost
    }
  }

  @objc private func selectSnippet(_ sender: NSMenuItem) {
    guard let id = sender.representedObject as? UUID,
          let snippet = SnippetStore.shared.snippet(id: id)
    else { return }
    onSelect?(snippet)
  }
}
