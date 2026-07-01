//
//  KeyboardShortcuts+Names.swift
//  Snippet Manager
//

import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  /// スニペットメニュー表示用ホットキー（デフォルト: Cmd + Shift + V）
  /// NSMenu をマウス位置に表示。ユーザー変更値は Recorder 経由で永続化
  static let showSnippetPicker = Self(
    "showSnippetPicker",
    default: .init(.v, modifiers: [.command, .shift])
  )
}
