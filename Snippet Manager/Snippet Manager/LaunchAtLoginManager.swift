//
//  LaunchAtLoginManager.swift
//  Snippet Manager
//

import Foundation
import ServiceManagement

/// ログイン時起動（macOS 13+ SMAppService）
enum LaunchAtLoginManager {
  static var isEnabled: Bool {
    SMAppService.mainApp.status == .enabled
  }

  static var requiresApproval: Bool {
    SMAppService.mainApp.status == .requiresApproval
  }

  @discardableResult
  static func setEnabled(_ enabled: Bool) -> String? {
    do {
      if enabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
      return nil
    } catch {
      return error.localizedDescription
    }
  }

  static func openSystemLoginItemsSettings() {
    SMAppService.openSystemSettingsLoginItems()
  }
}
