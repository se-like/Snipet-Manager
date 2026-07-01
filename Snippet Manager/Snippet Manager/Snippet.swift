//
//  Snippet.swift
//  Snippet Manager
//

import Foundation

/// スニペット1件分のデータモデル（UserDefaults 永続化用に Codable）
struct Snippet: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var content: String

    init(id: UUID = UUID(), title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}
