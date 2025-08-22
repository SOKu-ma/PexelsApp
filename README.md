## PexelsApp

### 開発環境

- Xcode 16.4
- Swift 6.1.2
- iOS 17.0+

## 概要

- Pexels API を利用した写真ブラウザ（一覧取得、ページング、詳細表示、フルスクリーン表示）
- 拡張性とテスト容易性を重視した実装

## 目次

- 概要
- 主な機能
- 技術スタック / ライブラリ
- アーキテクチャと工夫点
- API キー管理（.xcconfig）
- 実行手順（簡易）
- GIF（操作動画）
- 今後の課題

## 主な機能

- 写真一覧取得（ページング / 無限スクロール）
- 写真詳細表示（フルスクリーン、メタ情報表示）
- 画像キャッシュ（Kingfisher）
- API 呼び出しの抽象化（Repository / APIClient）
- 単体テスト（UseCase / RepositoryImpl）
- 表示モード切替（リスト / 2列グリッド）

## 技術スタック / ライブラリ

- Swift 6, SwiftUI
- The Composable Architecture (TCA)
- Kingfisher
- SwiftLint / SwiftFormat（ローカル導入推奨）

## アーキテクチャと工夫点

- クリーンアーキテクチャに基づくレイヤ分割（Domain / Infrastructure / Presentation）
- TCA による Feature 単位の状態管理と副作用分離
- Repository プロトコルと実装の分離によるモック差し替えによるテスト容易性
- APIClient による Info.plist 経由の API キー管理と共通ヘッダ処理（実装: `PexelsApp/Infrastructure/API/APIClient.swift`）
- DTO と Domain 間の Mapper 集約によるスキーマ変化への耐性
- 表示モード切替による一覧表示の柔軟性（リスト / 2列グリッド）

## API キー管理（.xcconfig）

- 管理方法: `Config/Production.xcconfig` に PEXELS_API_KEY を定義し、`Info.plist` の `PEXELS_API_KEY` を `$(PEXELS_API_KEY)` で注入
- 雛形ファイル: `Config/Production.sample.xcconfig`
- ローカル手順: `Production.sample.xcconfig` のコピーと `Config/Production.xcconfig` へのキー設定
- セキュリティ対応: 実キーのコミット禁止、提出前のトラッキング解除およびキーのローテーション

### 実装上のポイント

- Info.plist 経由の API キー読み取りと APIClient によるヘッダ一元化

### 運用上の方針

- CI による Secrets 管理とビルド時の環境注入（未適用）

## 実行手順（簡易）

- Xcode プロジェクト: `PexelsApp.xcodeproj` のオープン
- xcconfig 設定: `Config/Production.xcconfig` の作成と `PEXELS_API_KEY` の設定
- 実行環境: シミュレータまたは実機でのビルドと動作確認

## GIF（操作動画）

| 無限ローディング | 検索 |
|---|---|
| ![Infinity loading](Assets/Gif/InfinityLoading.gif) | ![Search](Assets/Gif/Search.gif) |

| ページング / フルスクリーン表示 | リスト / グリッド表示切り替え |
|---|---|
| ![Full screen](Assets/Gif/FullScreenImageDisplay.gif) | ![Bookmark](Assets/Gif/ListGridToggle.gif) |

## 今後の課題

- 画像読み込み改善: プリフェッチとダウンロード制御の最適化
- 品質向上: アクセシビリティ対応と テストの拡充

## 生成AI の活用

- ツール: ChatGPT、GitHub Copilot の補助的利用
- 利用目的: API 設計整理、README の構成案検討、テストコード作成支援
