//
//  PreferencesController.swift
//  Snippet Manager
//

import Combine
import Foundation

/// 環境設定ウィンドウの表示タブを制御
enum PreferencesTab: String, Hashable, CaseIterable {
  case general
  case shortcuts
  case history
  case snippets

  var title: String {
    switch self {
    case .general: "一般"
    case .shortcuts: "ショートカット"
    case .history: "履歴"
    case .snippets: "スニペット"
    }
  }

  var systemImage: String {
    switch self {
    case .general: "gearshape"
    case .shortcuts: "keyboard"
    case .history: "clock"
    case .snippets: "doc.text"
    }
  }
}

@MainActor
final class PreferencesController: ObservableObject {
  static let shared = PreferencesController()

  @Published var selectedTab: PreferencesTab = .general

  private init() {}
}
