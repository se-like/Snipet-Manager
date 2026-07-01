//
//  SnippetOutlineView.swift
//  Snippet Manager
//

import AppKit
import SwiftUI

/// アウトラインビュー（フォルダ階層・ドラッグ＆ドロップ）
struct SnippetOutlineView: NSViewRepresentable {
  @ObservedObject var store: SnippetStore
  @Binding var selection: EditorSelection?

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    scrollView.borderType = .noBorder

    let outlineView = NSOutlineView()
    outlineView.headerView = nil
    outlineView.rowSizeStyle = .medium
    outlineView.allowsEmptySelection = true
    outlineView.allowsMultipleSelection = false
    outlineView.focusRingType = .none
    outlineView.indentationPerLevel = 12
    outlineView.doubleAction = #selector(Coordinator.doubleClicked(_:))
    outlineView.target = context.coordinator

    let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("title"))
    column.title = ""
    column.isEditable = false
    outlineView.addTableColumn(column)
    outlineView.outlineTableColumn = column

    outlineView.dataSource = context.coordinator
    outlineView.delegate = context.coordinator
    outlineView.registerForDraggedTypes([.snippetDrag])
    outlineView.setDraggingSourceOperationMask(.move, forLocal: true)

    scrollView.documentView = outlineView
    context.coordinator.outlineView = outlineView
    context.coordinator.reload(from: store)

    return scrollView
  }

  func updateNSView(_ scrollView: NSScrollView, context: Context) {
    context.coordinator.parent = self
    context.coordinator.reload(from: store)
    context.coordinator.syncSelection(selection)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  // MARK: - Coordinator

  final class Coordinator: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    var parent: SnippetOutlineView
    weak var outlineView: NSOutlineView?
    private var folders: [SnippetFolder] = []

    init(parent: SnippetOutlineView) {
      self.parent = parent
    }

    func reload(from store: SnippetStore) {
      folders = store.folders.sorted { $0.index < $1.index }
      outlineView?.reloadData()
      expandAllFolders()
    }

    func syncSelection(_ selection: EditorSelection?) {
      guard let outlineView else { return }

      switch selection {
      case .folder(let folderID):
        guard let folder = folders.first(where: { $0.id == folderID }) else { return }
        let row = outlineView.row(forItem: OutlineItem.folder(folder))
        if row >= 0 { outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false) }
      case .snippet(_, let snippetID):
        guard
          let folder = folders.first(where: { $0.snippets.contains(where: { $0.id == snippetID }) }),
          let snippet = folder.snippets.first(where: { $0.id == snippetID })
        else { return }
        let item = OutlineItem.snippet(snippet, folderID: folder.id)
        let row = outlineView.row(forItem: item)
        if row >= 0 { outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false) }
      case nil:
        outlineView.deselectAll(nil)
      }
    }

    private func expandAllFolders() {
      guard let outlineView else { return }
      for folder in folders {
        outlineView.expandItem(OutlineItem.folder(folder), expandChildren: true)
      }
    }

    // MARK: NSOutlineViewDataSource

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
      if item == nil { return folders.count }
      guard let outlineItem = item as? OutlineItem else { return 0 }
      switch outlineItem {
      case .folder(let folder):
        return folder.snippets.count
      case .snippet:
        return 0
      }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
      if item == nil {
        return OutlineItem.folder(folders[index])
      }
      guard case .folder(let folder) = item as? OutlineItem else { return OutlineItem.folder(folders[0]) }
      return OutlineItem.snippet(folder.snippets[index], folderID: folder.id)
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
      (item as? OutlineItem)?.isFolder ?? false
    }

    // MARK: NSOutlineViewDelegate

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
      guard let outlineItem = item as? OutlineItem else { return nil }

      let identifier = NSUserInterfaceItemIdentifier("Cell")
      let cell: NSTableCellView
      if let reused = outlineView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
        cell = reused
      } else {
        cell = NSTableCellView()
        cell.identifier = identifier
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(imageView)
        cell.imageView = imageView

        let textField = NSTextField(labelWithString: "")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byTruncatingTail
        cell.addSubview(textField)
        cell.textField = textField

        NSLayoutConstraint.activate([
          imageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
          imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
          imageView.widthAnchor.constraint(equalToConstant: 16),
          imageView.heightAnchor.constraint(equalToConstant: 16),
          textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 6),
          textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -4),
          textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
      }

      switch outlineItem {
      case .folder(let folder):
        cell.imageView?.image = folderIcon
        cell.textField?.stringValue = folder.title
      case .snippet(let snippet, _):
        cell.imageView?.image = snippetIcon
        cell.textField?.stringValue = snippet.title.isEmpty ? "（無題）" : snippet.title
      }

      return cell
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
      guard let outlineView else { return }
      let row = outlineView.selectedRow
      guard row >= 0, let item = outlineView.item(atRow: row) as? OutlineItem else {
        parent.selection = nil
        return
      }

      switch item {
      case .folder(let folder):
        parent.selection = .folder(folder.id)
      case .snippet(let snippet, let folderID):
        parent.selection = .snippet(folderID: folderID, snippetID: snippet.id)
      }
    }

    // MARK: Drag & Drop

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
      guard case .snippet(let snippet, let folderID) = item as? OutlineItem else { return nil }
      let pasteboardItem = NSPasteboardItem()
      let payload = "\(snippet.id.uuidString)|\(folderID.uuidString)"
      pasteboardItem.setString(payload, forType: .snippetDrag)
      return pasteboardItem
    }

    func outlineView(
      _ outlineView: NSOutlineView,
      validateDrop info: NSDraggingInfo,
      proposedItem item: Any?,
      proposedChildIndex index: Int
    ) -> NSDragOperation {
      guard info.draggingPasteboard.string(forType: .snippetDrag) != nil else { return [] }

      if let outlineItem = item as? OutlineItem {
        switch outlineItem {
        case .folder:
          return .move
        case .snippet:
          return index == NSOutlineViewDropOnItemIndex ? [] : .move
        }
      }

      return []
    }

    func outlineView(
      _ outlineView: NSOutlineView,
      acceptDrop info: NSDraggingInfo,
      item: Any?,
      childIndex index: Int
    ) -> Bool {
      guard
        let payload = info.draggingPasteboard.string(forType: .snippetDrag),
        let dragItem = Self.parseDragPayload(payload)
      else { return false }

      let destinationFolderID: UUID
      let destinationIndex: Int

      if let outlineItem = item as? OutlineItem {
        switch outlineItem {
        case .folder(let folder):
          destinationFolderID = folder.id
          destinationIndex = index == NSOutlineViewDropOnItemIndex ? folder.snippets.count : index
        case .snippet(_, let folderID):
          destinationFolderID = folderID
          destinationIndex = index == NSOutlineViewDropOnItemIndex ? 0 : index
        }
      } else {
        return false
      }

      Task { @MainActor in
        parent.store.moveSnippet(
          snippetID: dragItem.0,
          from: dragItem.1,
          to: destinationFolderID,
          at: destinationIndex
        )
        parent.selection = .snippet(folderID: destinationFolderID, snippetID: dragItem.0)
      }

      return true
    }

    @objc func doubleClicked(_ sender: NSOutlineView) {
      let row = sender.clickedRow
      guard row >= 0, let item = sender.item(atRow: row) as? OutlineItem else { return }
      if case .folder(let folder) = item {
        sender.expandItem(item, expandChildren: true)
        parent.selection = .folder(folder.id)
      }
    }

    private var folderIcon: NSImage {
      let image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!
      image.isTemplate = true
      return image
    }

    private var snippetIcon: NSImage {
      let image = NSImage(systemSymbolName: "doc.plaintext", accessibilityDescription: nil)!
      image.isTemplate = true
      return image
    }

    private static func parseDragPayload(_ payload: String) -> (snippetID: UUID, sourceFolderID: UUID)? {
      let parts = payload.split(separator: "|", maxSplits: 1).map(String.init)
      guard parts.count == 2,
            let snippetID = UUID(uuidString: parts[0]),
            let sourceFolderID = UUID(uuidString: parts[1])
      else { return nil }
      return (snippetID, sourceFolderID)
    }
  }
}

// MARK: - Models

enum EditorSelection: Hashable {
  case folder(UUID)
  case snippet(folderID: UUID, snippetID: UUID)
}

private enum OutlineItem: Hashable {
  case folder(SnippetFolder)
  case snippet(Snippet, folderID: UUID)

  var isFolder: Bool {
    if case .folder = self { return true }
    return false
  }
}

private extension NSPasteboard.PasteboardType {
  static let snippetDrag = NSPasteboard.PasteboardType("jp.co.crowdcloud.Snippet-Manager.snippet-drag")
}
