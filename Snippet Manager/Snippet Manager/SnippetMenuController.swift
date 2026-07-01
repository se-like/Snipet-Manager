//
//  SnippetMenuController.swift
//  Snippet Manager
//

import AppKit

/// 番号付き NSMenu ポップアップ（フォルダ階層・数値キー）
@MainActor
final class SnippetMenuController: NSObject {
  static let shared = SnippetMenuController()

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

  private var previousApp: NSRunningApplication?
  var onSelect: ((Snippet) -> Void)?

  private override init() {
    super.init()
  }

  func previousApplication() -> NSRunningApplication? {
    previousApp
  }

  /// ホットキー検知時: マウス位置にスニペットメニューを表示
  func popUpSnippetMenu() {
    rememberFrontmostApp()
    let menu = buildSnippetMenu(includeSectionHeader: true)
    menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
  }

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

  // MARK: - Menu Building

  private func buildSnippetMenu(includeSectionHeader: Bool) -> NSMenu {
    let menu = NSMenu(title: "スニペット")

    if includeSectionHeader {
      let header = NSMenuItem(title: "スニペット", action: nil, keyEquivalent: "")
      header.isEnabled = false
      menu.addItem(header)
    }

    appendFolderItems(to: menu, startListNumber: 1)
    return menu
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
