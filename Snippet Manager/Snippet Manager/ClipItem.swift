//
//  ClipItem.swift
//  Snippet Manager
//

import Foundation

/// クリップボード履歴1件分のデータモデル（JSON ファイル永続化用に Codable）
struct ClipItem: Identifiable, Codable, Equatable, Hashable {
  let id: UUID
  var content: String
  var copiedAt: Date

  init(id: UUID = UUID(), content: String, copiedAt: Date = Date()) {
    self.id = id
    self.content = content
    self.copiedAt = copiedAt
  }
}
