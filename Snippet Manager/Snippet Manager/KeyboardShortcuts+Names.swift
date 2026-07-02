//
//  KeyboardShortcuts+Names.swift
//  Snippet Manager
//

import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  /// メインメニュー（履歴 + スニペット）表示用ホットキー（デフォルト: Cmd + Shift + V）
  /// Clipy の「メイン」ショートカットに相当。NSMenu をマウス位置に表示
  static let showMainMenu = Self(
    "showMainMenu",
    initial: .init(.v, modifiers: [.command, .shift])
  )

  /// クリップボード履歴メニュー表示用ホットキー（デフォルト: Cmd + Control + V）
  /// Clipy の「履歴」ショートカットに相当
  static let showHistoryMenu = Self(
    "showHistoryMenu",
    initial: .init(.v, modifiers: [.command, .control])
  )

  /// スニペットメニュー表示用ホットキー（デフォルト: Cmd + Shift + B）
  /// Clipy の「スニペット」ショートカットに相当。ユーザー変更値は Recorder 経由で永続化
  static let showSnippetPicker = Self(
    "showSnippetPicker",
    initial: .init(.b, modifiers: [.command, .shift])
  )
}
