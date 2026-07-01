//
//  SnippetFolder.swift
//  Snippet Manager
//

import Foundation

/// フォルダ階層でスニペットを格納
struct SnippetFolder: Identifiable, Codable, Equatable, Hashable {
  let id: UUID
  var title: String
  var index: Int
  var snippets: [Snippet]

  init(id: UUID = UUID(), title: String, index: Int = 0, snippets: [Snippet] = []) {
    self.id = id
    self.title = title
    self.index = index
    self.snippets = snippets
  }
}
