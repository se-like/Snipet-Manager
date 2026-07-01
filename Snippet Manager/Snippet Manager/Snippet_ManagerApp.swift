//
//  Snippet_ManagerApp.swift
//  Snippet Manager
//

import SwiftUI

@main
struct Snippet_ManagerApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    // 常駐エージェントのためメインウィンドウは持たない（設定のみ提供）
    Settings {
      SettingsView()
    }
  }
}
