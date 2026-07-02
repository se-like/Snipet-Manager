//
//  PreferencesView.swift
//  Snippet Manager
//

import KeyboardShortcuts
import SwiftUI

/// サイドバー型の環境設定（一般・ショートカット・スニペット）
struct PreferencesView: View {
  @ObservedObject private var controller = PreferencesController.shared

  var body: some View {
    NavigationSplitView {
      List(selection: $controller.selectedTab) {
        ForEach(PreferencesTab.allCases, id: \.self) { tab in
          Label(tab.title, systemImage: tab.systemImage)
            .tag(tab)
        }
      }
      .listStyle(.sidebar)
      .navigationSplitViewColumnWidth(min: 148, ideal: 168, max: 200)
    } detail: {
      detailContent
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    .frame(minWidth: 720, minHeight: 520)
    .background(Color(nsColor: .windowBackgroundColor))
  }

  @ViewBuilder
  private var detailContent: some View {
    switch controller.selectedTab {
    case .general:
      GeneralPreferencesView()
    case .shortcuts:
      ShortcutsPreferencesView()
    case .history:
      HistoryPreferencesView()
    case .snippets:
      SnippetsPreferencesView()
    }
  }
}

// MARK: - 一般

struct GeneralPreferencesView: View {
  @State private var launchAtLogin = LaunchAtLoginManager.isEnabled
  @State private var errorMessage: String?

  var body: some View {
    Form {
      Section {
        Toggle("ログイン時に起動", isOn: $launchAtLogin)
          .onChange(of: launchAtLogin) { _, newValue in
            if let error = LaunchAtLoginManager.setEnabled(newValue) {
              launchAtLogin = LaunchAtLoginManager.isEnabled
              errorMessage = error
            }
          }

        if LaunchAtLoginManager.requiresApproval {
          HStack {
            Text("システムの承認が必要です")
              .foregroundStyle(.secondary)
            Spacer()
            Button("ログイン項目を開く") {
              LaunchAtLoginManager.openSystemLoginItemsSettings()
            }
          }
        }
      } header: {
        Text("起動")
      } footer: {
        Text("Mac のログイン時に Snippet Manager を自動起動します。初回は「システム設定 → 一般 → ログイン時に開く」での許可が必要な場合があります。")
      }
    }
    .formStyle(.grouped)
    .padding()
    .navigationTitle("一般")
    .onAppear {
      launchAtLogin = LaunchAtLoginManager.isEnabled
    }
    .alert("ログイン時起動を設定できません", isPresented: Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } }
    )) {
      Button("ログイン項目を開く") {
        LaunchAtLoginManager.openSystemLoginItemsSettings()
      }
      Button("OK", role: .cancel) {}
    } message: {
      Text(errorMessage ?? "")
    }
  }
}

// MARK: - ショートカット

struct ShortcutsPreferencesView: View {
  var body: some View {
    Form {
      Section {
        LabeledContent("メインメニューを開く（履歴 + スニペット）") {
          KeyboardShortcuts.Recorder(for: .showMainMenu)
        }
        LabeledContent("履歴メニューを開く") {
          KeyboardShortcuts.Recorder(for: .showHistoryMenu)
        }
        LabeledContent("スニペットメニューを開く") {
          KeyboardShortcuts.Recorder(for: .showSnippetPicker)
        }
      } header: {
        Text("グローバルショートカット")
      } footer: {
        Text("設定したキーで番号付きメニューがマウス位置に表示されます。変更はすぐに反映されます。")
      }
    }
    .formStyle(.grouped)
    .padding()
    .navigationTitle("ショートカット")
  }
}

// MARK: - 履歴

struct HistoryPreferencesView: View {
  @ObservedObject private var store = ClipboardHistoryStore.shared
  @State private var showClearConfirmation = false

  var body: some View {
    Form {
      Section {
        Stepper(value: $store.maxHistorySize, in: ClipboardHistoryStore.maxHistorySizeRange) {
          LabeledContent("履歴の最大保存件数", value: "\(store.maxHistorySize) 件")
        }
        Stepper(value: $store.inlineItemCount, in: ClipboardHistoryStore.inlineItemCountRange) {
          LabeledContent("メニューに直接表示する件数", value: "\(store.inlineItemCount) 件")
        }
        Stepper(value: $store.itemsPerFolder, in: ClipboardHistoryStore.itemsPerFolderRange) {
          LabeledContent("フォルダあたりの件数", value: "\(store.itemsPerFolder) 件")
        }
      } header: {
        Text("クリップボード履歴")
      } footer: {
        Text("コピーしたテキストを自動で記録します。直接表示件数を超えた分は「11 - 20」のようなフォルダにまとまります。パスワードマネージャ等が秘匿指定したデータは記録されません。")
      }

      Section {
        LabeledContent("現在の履歴", value: "\(store.items.count) 件")
        Button("履歴を消去…", role: .destructive) {
          showClearConfirmation = true
        }
        .disabled(store.items.isEmpty)
      } header: {
        Text("管理")
      }
    }
    .formStyle(.grouped)
    .padding()
    .navigationTitle("履歴")
    .confirmationDialog(
      "クリップボード履歴をすべて消去しますか？",
      isPresented: $showClearConfirmation
    ) {
      Button("消去", role: .destructive) {
        store.clearHistory()
      }
      Button("キャンセル", role: .cancel) {}
    } message: {
      Text("この操作は取り消せません。")
    }
  }
}

// MARK: - スニペット

struct SnippetsPreferencesView: View {
  var body: some View {
    VStack(spacing: 0) {
      SnippetEditorView()
      Divider()
      snippetHelpBar
    }
    .navigationTitle("スニペット")
  }

  private var snippetHelpBar: some View {
    HStack(alignment: .top, spacing: 20) {
      Label("追加: フォルダを選択 → ⌘N", systemImage: "plus.circle")
      Label("移動: スニペットをドラッグ＆ドロップ", systemImage: "arrow.right.arrow.left")
      Label("削除: 選択 → Delete", systemImage: "trash")
      Spacer()
    }
    .font(.caption)
    .foregroundStyle(.secondary)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Color(nsColor: .controlBackgroundColor))
  }
}
