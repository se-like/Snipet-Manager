//
//  SnippetStore.swift
//  Snippet Manager
//

import Combine
import Foundation

/// UserDefaults ベースのスニペット永続化（フォルダ階層）
@MainActor
final class SnippetStore: ObservableObject {
  static let shared = SnippetStore()

  @Published private(set) var folders: [SnippetFolder] = []

  private let foldersKey = "snippetFolders"
  private let legacySnippetsKey = "snippets"
  private let defaults = UserDefaults.standard

  private init() {
    load()
  }

  var allSnippets: [Snippet] {
    folders
      .sorted { $0.index < $1.index }
      .flatMap(\.snippets)
  }

  func snippet(id: UUID) -> Snippet? {
    for folder in folders {
      if let snippet = folder.snippets.first(where: { $0.id == id }) {
        return snippet
      }
    }
    return nil
  }

  func folder(id: UUID) -> SnippetFolder? {
    folders.first { $0.id == id }
  }

  func filtered(by query: String) -> [Snippet] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let source = allSnippets
    guard !trimmed.isEmpty else { return source }

    return source.filter { snippet in
      snippet.title.localizedCaseInsensitiveContains(trimmed)
        || snippet.content.localizedCaseInsensitiveContains(trimmed)
    }
  }

  // MARK: - Folder

  @discardableResult
  func addFolder(title: String) -> UUID {
    let folder = SnippetFolder(title: title, index: folders.count)
    folders.append(folder)
    save()
    return folder.id
  }

  func deleteFolder(id: UUID) {
    folders.removeAll { $0.id == id }
    reindexFolders()
    save()
  }

  func updateFolderTitle(id: UUID, title: String) {
    guard let index = folders.firstIndex(where: { $0.id == id }) else { return }
    folders[index].title = title
    save()
  }

  func moveFolder(from sourceIndex: Int, to destinationIndex: Int) {
    guard folders.indices.contains(sourceIndex), folders.indices.contains(destinationIndex) else { return }
    let folder = folders.remove(at: sourceIndex)
    folders.insert(folder, at: destinationIndex)
    reindexFolders()
    save()
  }

  // MARK: - Snippet

  func addSnippet(to folderID: UUID, snippet: Snippet) {
    guard let index = folders.firstIndex(where: { $0.id == folderID }) else { return }
    folders[index].snippets.append(snippet)
    save()
  }

  func updateSnippet(_ snippet: Snippet, in folderID: UUID) {
    guard let folderIndex = folders.firstIndex(where: { $0.id == folderID }),
          let snippetIndex = folders[folderIndex].snippets.firstIndex(where: { $0.id == snippet.id })
    else { return }
    folders[folderIndex].snippets[snippetIndex] = snippet
    save()
  }

  func deleteSnippet(id: UUID, from folderID: UUID) {
    guard let folderIndex = folders.firstIndex(where: { $0.id == folderID }) else { return }
    folders[folderIndex].snippets.removeAll { $0.id == id }
    save()
  }

  func folder(containing snippetID: UUID) -> SnippetFolder? {
    folders.first { folder in
      folder.snippets.contains { $0.id == snippetID }
    }
  }

  /// スニペットを別フォルダへ移動（ドラッグ＆ドロップ用）
  func moveSnippet(
    snippetID: UUID,
    from sourceFolderID: UUID,
    to destinationFolderID: UUID,
    at destinationIndex: Int
  ) {
    guard let sourceFolderIndex = folders.firstIndex(where: { $0.id == sourceFolderID }),
          let snippetIndex = folders[sourceFolderIndex].snippets.firstIndex(where: { $0.id == snippetID }),
          let destinationFolderIndex = folders.firstIndex(where: { $0.id == destinationFolderID })
    else { return }

    let snippet = folders[sourceFolderIndex].snippets.remove(at: snippetIndex)
    var insertIndex = max(0, min(destinationIndex, folders[destinationFolderIndex].snippets.count))

    // 同一フォルダ内で後方へ移動する場合、削除後のインデックスを補正
    if sourceFolderID == destinationFolderID, snippetIndex < insertIndex {
      insertIndex -= 1
    }

    folders[destinationFolderIndex].snippets.insert(snippet, at: insertIndex)
    save()
  }

  /// スニペットをフォルダ末尾へ移動
  func moveSnippet(snippetID: UUID, toFolder destinationFolderID: UUID) {
    guard let sourceFolder = folder(containing: snippetID) else { return }
    let destinationCount = folders.first(where: { $0.id == destinationFolderID })?.snippets.count ?? 0
    moveSnippet(
      snippetID: snippetID,
      from: sourceFolder.id,
      to: destinationFolderID,
      at: destinationCount
    )
  }

  // MARK: - Persistence

  private func load() {
    if let data = defaults.data(forKey: foldersKey),
       let decoded = try? JSONDecoder().decode([SnippetFolder].self, from: data),
       !decoded.isEmpty
    {
      folders = decoded
      return
    }

    if let data = defaults.data(forKey: legacySnippetsKey),
       let legacy = try? JSONDecoder().decode([Snippet].self, from: data),
       !legacy.isEmpty
    {
      folders = [SnippetFolder(title: "スニペット", index: 0, snippets: legacy)]
      save()
      return
    }

    folders = [SnippetFolder(title: "スニペット", index: 0, snippets: Self.defaultSnippets)]
    save()
  }

  private func save() {
    guard let data = try? JSONEncoder().encode(folders) else { return }
    defaults.set(data, forKey: foldersKey)
  }

  private func reindexFolders() {
    for index in folders.indices {
      folders[index].index = index
    }
  }

  private static let defaultSnippets: [Snippet] = [
    Snippet(title: "挨拶", content: "お世話になっております。\nよろしくお願いいたします。"),
    Snippet(title: "メール署名", content: "────────────────\n山田 太郎\nexample@email.com"),
    Snippet(title: "コード雛形", content: "func main() {\n    print(\"Hello, world!\")\n}"),
  ]
}
