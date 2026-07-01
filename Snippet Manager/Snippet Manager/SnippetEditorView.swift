//
//  SnippetEditorView.swift
//  Snippet Manager
//

import SwiftUI

/// スニペット編集 UI（アウトライン + ドラッグ＆ドロップ + フォルダ編集）
struct SnippetEditorView: View {
  @ObservedObject private var store = SnippetStore.shared
  @State private var selection: EditorSelection?
  @State private var editingTitle = ""
  @State private var editingContent = ""
  @State private var editingFolderTitle = ""

  var body: some View {
    VStack(spacing: 0) {
      editorToolbar
      Divider()
      HSplitView {
        VStack(alignment: .leading, spacing: 0) {
          Text("フォルダとスニペット")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
          SnippetOutlineView(store: store, selection: $selection)
        }
        .frame(minWidth: 220, idealWidth: 240, maxWidth: 300)

        editorPane
          .frame(minWidth: 320)
      }
    }
    .background(Color(nsColor: .windowBackgroundColor))
    .onAppear(perform: bootstrapSelection)
    .onChange(of: selection) { _, _ in
      syncEditorFromSelection()
    }
    .onDeleteCommand {
      deleteSelection()
    }
  }

  private var editorToolbar: some View {
    HStack(spacing: 12) {
      Button { addFolder() } label: {
        Label("フォルダを追加", systemImage: "folder.badge.plus")
      }
      .buttonStyle(.bordered)
      .help("新しいフォルダを作成し、選択状態にします")

      Button { addSnippet() } label: {
        Label("スニペットを追加", systemImage: "doc.badge.plus")
      }
      .buttonStyle(.borderedProminent)
      .keyboardShortcut("n", modifiers: .command)
      .help("選択中のフォルダにスニペットを追加します")

      Button(role: .destructive) { deleteSelection() } label: {
        Label("削除", systemImage: "trash")
      }
      .buttonStyle(.bordered)
      .disabled(selection == nil)
      .help("選択中のフォルダまたはスニペットを削除します")

      Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(Color(nsColor: .controlBackgroundColor))
  }

  private var editorPane: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let selection {
        switch selection {
        case .folder(let folderID):
          folderEditor(folderID: folderID)
        case .snippet(let folderID, let snippetID):
          snippetEditor(folderID: folderID, snippetID: snippetID)
        }
      } else {
        emptySelectionView
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  private var emptySelectionView: some View {
    ContentUnavailableView(
      "フォルダまたはスニペットを選択",
      systemImage: "sidebar.left",
      description: Text("左の一覧でフォルダ名を編集するか、スニペットをドラッグしてフォルダへ移動できます")
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private func folderEditor(folderID: UUID) -> some View {
    if let folder = store.folder(id: folderID) {
      VStack(alignment: .leading, spacing: 12) {
        Label("フォルダ", systemImage: "folder")
          .font(.headline)

        Text("フォルダ名")
          .font(.caption)
          .foregroundStyle(.secondary)
        TextField("フォルダ名", text: $editingFolderTitle)
          .textFieldStyle(.roundedBorder)
          .onChange(of: editingFolderTitle) { _, newValue in
            store.updateFolderTitle(id: folderID, title: newValue)
          }

        GroupBox {
          VStack(alignment: .leading, spacing: 8) {
            Text("スニペット \(folder.snippets.count) 件")
              .font(.subheadline)
            Text("・スニペットをこのフォルダへドラッグ＆ドロップ\n・「スニペットを追加」で新規作成")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(4)
        }

        if folder.snippets.isEmpty {
          ContentUnavailableView(
            "スニペットがありません",
            systemImage: "tray",
            description: Text("「スニペットを追加」を押すか、他フォルダからドラッグしてください")
          )
          .frame(maxHeight: 180)
        }

        Spacer()
      }
    }
  }

  @ViewBuilder
  private func snippetEditor(folderID: UUID, snippetID: UUID) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      if let folder = store.folder(id: folderID) {
        Text("フォルダ: \(folder.title)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text("タイトル")
        .font(.caption)
        .foregroundStyle(.secondary)
      TextField("タイトル", text: $editingTitle)
        .textFieldStyle(.roundedBorder)
        .onChange(of: editingTitle) { _, newValue in
          persistSnippet(folderID: folderID, snippetID: snippetID, title: newValue, content: editingContent)
        }

      Text("内容")
        .font(.caption)
        .foregroundStyle(.secondary)

      ZStack(alignment: .topLeading) {
        TextEditor(text: $editingContent)
          .font(.system(size: 14))
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(Color.secondary.opacity(0.25))
          )
          .onChange(of: editingContent) { _, newValue in
            persistSnippet(folderID: folderID, snippetID: snippetID, title: editingTitle, content: newValue)
          }

        if editingContent.isEmpty {
          Text("スニペットの内容を入力してください")
            .font(.system(size: 14))
            .foregroundStyle(.tertiary)
            .padding(.top, 8)
            .padding(.leading, 5)
            .allowsHitTesting(false)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  // MARK: - Actions

  private func bootstrapSelection() {
    if selection != nil {
      syncEditorFromSelection()
      return
    }
    if let folder = store.folders.sorted(by: { $0.index < $1.index }).first {
      if let snippet = folder.snippets.first {
        selection = .snippet(folderID: folder.id, snippetID: snippet.id)
      } else {
        selection = .folder(folder.id)
      }
      syncEditorFromSelection()
    }
  }

  private func syncEditorFromSelection() {
    switch selection {
    case .folder(let folderID):
      editingFolderTitle = store.folder(id: folderID)?.title ?? ""
      editingTitle = ""
      editingContent = ""
    case .snippet(let folderID, let snippetID):
      if let snippet = store.folder(id: folderID)?.snippets.first(where: { $0.id == snippetID }) {
        editingTitle = snippet.title
        editingContent = snippet.content
      }
      editingFolderTitle = ""
    case nil:
      editingTitle = ""
      editingContent = ""
      editingFolderTitle = ""
    }
  }

  private func persistSnippet(folderID: UUID, snippetID: UUID, title: String, content: String) {
    store.updateSnippet(Snippet(id: snippetID, title: title, content: content), in: folderID)
  }

  private func addFolder() {
    let folderID = store.addFolder(title: "新規フォルダ")
    selection = .folder(folderID)
    syncEditorFromSelection()
  }

  private func addSnippet() {
    let folderID: UUID
    switch selection {
    case .folder(let id):
      folderID = id
    case .snippet(let id, _):
      folderID = id
    case nil:
      if let folder = store.folders.sorted(by: { $0.index < $1.index }).first {
        folderID = folder.id
      } else {
        folderID = store.addFolder(title: "スニペット")
      }
    }

    let snippet = Snippet(title: "新規スニペット", content: "")
    store.addSnippet(to: folderID, snippet: snippet)
    selection = .snippet(folderID: folderID, snippetID: snippet.id)
    syncEditorFromSelection()
  }

  private func deleteSelection() {
    guard let selection else { return }
    switch selection {
    case .folder(let folderID):
      store.deleteFolder(id: folderID)
      self.selection = nil
      bootstrapSelection()
    case .snippet(let folderID, let snippetID):
      store.deleteSnippet(id: snippetID, from: folderID)
      if let folder = store.folder(id: folderID) {
        self.selection = .folder(folderID)
      } else {
        self.selection = nil
        bootstrapSelection()
      }
      syncEditorFromSelection()
    }
  }
}
