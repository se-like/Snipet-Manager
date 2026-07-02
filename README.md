# Snippet Manager

macOS 専用の常駐型スニペット & クリップボード履歴管理アプリです。ホットキーで番号付きメニューを開き、選択したテキストを作業中のアプリへ自動ペーストします。コピーしたテキストは Clipy と同等の使い勝手で自動記録されます。

**English documentation:** [README.en.md](README.en.md)

---

## 主な機能

| 機能 | 説明 |
|------|------|
| 常駐動作 | Dock アイコン非表示（メニューバーのみ） |
| クリップボード履歴 | コピーしたテキストを自動記録（最大 100 件・重複排除・秘匿コピー除外） |
| グローバルホットキー | メイン `⌘⇧V` / 履歴 `⌘⌃V` / スニペット `⌘⇧B`（ユーザー変更可） |
| メニュー | 番号付き `NSMenu`（履歴インライン + フォルダ分割・数値キー選択） |
| 自動ペースト | 選択後、元アプリへフォーカスを戻して `⌘V` をエミュレート |
| スニペット管理 | フォルダ階層・ドラッグ＆ドロップ・リアルタイム保存 |
| ログイン時起動 | 環境設定からオン/オフ |

## 動作環境

- macOS 14.0 以降
- Xcode 15 以降（ビルド時）
- **アクセシビリティ権限**（自動ペーストに必須）

## クイックスタート

### 1. ビルドとインストール

```zsh
cd "Snippet Manager"
xcodebuild -scheme "Snippet Manager" -configuration Release build
cp -R "$(find ~/Library/Developer/Xcode/DerivedData -name 'Snippet Manager.app' -path '*/Release/*' | head -1)" /Applications/
open -a "Snippet Manager"
```

または Xcode で `Snippet Manager.xcodeproj` を開き **⌘R** で実行。

### 2. 初回セットアップ

1. **アクセシビリティ** — システム設定 → プライバシーとセキュリティ → アクセシビリティ で `Snippet Manager` をオン
2. **メニューバー** — 右上のクリップ（📎）アイコンを確認（隠れている場合は `Control` を押しながらメニューバー左端をドラッグ）
3. **環境設定** — メニュー → **環境設定…**（⌘,）

### 3. 履歴・スニペットを使う

1. 任意のアプリでカーソルを置く
2. ホットキー（メイン `⌘⇧V` / 履歴 `⌘⌃V` / スニペット `⌘⇧B`）を押す
3. 履歴・スニペットを選択（または `1`〜`9` / `0` キー）
4. 自動でペーストされる

## ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [利用ガイド（日本語）](docs/利用ガイド.md) | 操作手順・トラブルシューティング |
| [User Guide (English)](docs/USER-GUIDE.md) | End-user instructions |
| [詳細設計書（日本語）](docs/設計書.md) | アーキテクチャ・データモデル・処理フロー |
| [Detailed Design (English)](docs/DESIGN.md) | Technical design document |
| [開発者向けセットアップ](docs/SETUP.md) | 依存関係・プロジェクト構成 |

## 依存パッケージ

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) 3.x — グローバルホットキーとユーザー設定

## ライセンス

本プロジェクトは [MIT License](LICENSE) で公開しています。

- 依存ライブラリのライセンス表記は [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) を参照してください
- クリップボード履歴機能は [Clipy](https://github.com/Clipy/Clipy)（MIT License）の**挙動を参考**にしていますが、Clipy のソースコード・アイコン等の成果物は一切含みません（Clipy プロジェクトとは無関係です）

## リポジトリ

https://github.com/se-like/Snipet-Manager
