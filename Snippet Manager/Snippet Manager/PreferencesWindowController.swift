//
//  PreferencesWindowController.swift
//  Snippet Manager
//

import AppKit
import SwiftUI

/// 環境設定ウィンドウ
@MainActor
final class PreferencesWindowController: NSObject, NSWindowDelegate {
  static let shared = PreferencesWindowController()

  private var window: NSWindow?

  private override init() {
    super.init()
  }

  func show(tab: PreferencesTab = .general) {
    PreferencesController.shared.selectedTab = tab

    if let window {
      window.makeKeyAndOrderFront(nil)
      NSApp.activate()
      return
    }

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 740, height: 540),
      styleMask: [.titled, .closable, .resizable, .miniaturizable],
      backing: .buffered,
      defer: false
    )
    window.title = "環境設定"
    window.backgroundColor = .windowBackgroundColor
    window.contentView = NSHostingView(rootView: PreferencesView())
    window.minSize = NSSize(width: 680, height: 480)
    window.center()
    window.delegate = self
    window.isReleasedWhenClosed = false
    window.makeKeyAndOrderFront(nil)
    NSApp.activate()
    self.window = window
  }

  func windowWillClose(_ notification: Notification) {
    window?.orderOut(nil)
  }
}
