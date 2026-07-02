//
//  PasteController.swift
//  Snippet Manager
//

import AppKit
import ApplicationServices
import Foundation

/// クリップボード書き込みと CGEvent による Cmd+V ペーストを担当
enum PasteController {
  private static let pasteDelay: TimeInterval = 0.1
  /// macOS の仮想キーコード: V キー
  private static let vKeyCode: CGKeyCode = 9

  /// ① ペーストボード → ② フォーカス返却 → ③ 遅延 → ④ Cmd+V
  @MainActor
  static func paste(text: String, returningFocusTo app: NSRunningApplication?) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)

    if let app {
      // macOS 14+ の協調的アクティベーション: 自アプリが権利を譲ってから前面化する
      NSApp.yieldActivation(to: app)
      app.activate()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + pasteDelay) {
      simulateCommandV()
    }
  }

  /// CGEvent で KeyDown / KeyUp の Cmd+V をシステムへ送信
  private static func simulateCommandV() {
    guard AXIsProcessTrusted() else {
      // アクセシビリティ未許可時はペーストイベントを送れない
      NSLog("PasteController: Accessibility permission is required for simulated paste.")
      return
    }

    let source = CGEventSource(stateID: .hidSystemState)

    guard
      let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true),
      let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
    else {
      return
    }

    keyDown.flags = .maskCommand
    keyUp.flags = .maskCommand

    keyDown.post(tap: .cghidEventTap)
    keyUp.post(tap: .cghidEventTap)
  }

  /// 初回ペースト前にアクセシビリティ許可ダイアログを表示する
  static func requestAccessibilityIfNeeded() {
    guard !AXIsProcessTrusted() else { return }

    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    AXIsProcessTrustedWithOptions(options)
  }
}
