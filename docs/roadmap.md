# やさいせんせい 開発ロードマップ

## 🎯 プロジェクト進捗

### ✅ 完了済み（2025年7月）
- [x] Supabaseクラウド開発環境構築
- [x] データベース設計・テーブル作成（5テーブル）
- [x] 12種類の野菜マスタデータ投入
- [x] Row Level Security (RLS) 設定
- [x] 認証設定（Android用、カスタムURIスキーム）
- [x] ストレージ設定（写真用、50MB制限）
- [x] 開発用スクリプト作成
- [x] プロジェクトドキュメント整備

## 🚧 開発予定（フェーズ1 MVP）

### 1. Flutter基本画面実装（優先度：高）
**目標期間：2-3週間**

#### 認証機能
- [x] ログイン画面
- [x] サインアップ画面  
- [x] Supabase Auth連携

#### 野菜管理画面
- [ ] 野菜一覧画面（栽培中の野菜表示）
- [ ] 野菜詳細画面（次の作業予定・履歴表示）
- [ ] 野菜登録画面（12種類選択・入力フォーム）

#### AI相談画面
- [ ] チャット画面（メッセージ送受信）
- [ ] 会話履歴表示

#### 設定画面
- [ ] 通知設定画面（時間帯・頻度調整）

### 2. Python AI相談API実装（優先度：高）
**目標期間：1週間**

- [ ] FastAPIサーバー構築
- [ ] OpenAI GPT-4o-mini連携
- [ ] 野菜特化プロンプト設計
- [ ] 会話履歴管理機能
- [ ] エラーハンドリング

### 3. プッシュ通知機能（優先度：高）
**目標期間：1-2週間**

#### Supabase Functions
- [ ] 通知スケジュール管理
- [ ] 作業タイミング計算ロジック
- [ ] 水やり通知ロジック

#### Firebase Cloud Messaging
- [ ] FCM設定・連携
- [ ] プッシュ通知送信機能
- [ ] 通知権限管理

### 4. フィードバック機能（優先度：中）
**目標期間：1週間**

- [ ] 通知後フィードバック収集画面
- [ ] フィードバックデータ保存
- [ ] 次回通知タイミング調整ロジック

### 5. テスト・品質向上（優先度：中）
**目標期間：1週間**

- [ ] 単体テスト実装
- [ ] 統合テスト実装
- [ ] UIテスト
- [ ] パフォーマンス最適化

## 🔮 フェーズ2（拡張機能）

### 撮影・記録機能
- [ ] 撮影モード機能
- [ ] 写真タイムラプス機能
- [ ] パラパラ漫画機能

### 高度な機能
- [ ] 収穫記録・アーカイブ機能
- [ ] カレンダー画面
- [ ] 天気API連携
- [ ] コミュニティ機能

## 📅 マイルストーン

| マイルストーン | 予定日 | 内容 |
|--------------|--------|------|
| MVP Alpha | 2025年8月中旬 | 基本機能完成 |
| MVP Beta | 2025年8月下旬 | テスト・改善完了 |
| MVP リリース | 2025年9月上旬 | Android ストア公開 |
| フェーズ2開始 | 2025年9月中旬 | 拡張機能開発開始 |

## 🎯 MVP完成の定義

以下の機能がすべて動作すること：
- [x] ユーザー登録・ログイン
- [ ] 野菜の登録・管理
- [ ] 栽培スケジュールに基づく通知
- [ ] AIへの相談機能
- [ ] 通知フィードバック機能

## 🚨 リスク・課題

### 技術的リスク
- Flutter開発経験の習得
- AI回答品質の確保
- 通知タイミングの精度

### スケジュールリスク  
- 個人開発のため時間確保が課題
- 予期しない技術的問題による遅延

### 対策
- 小さな機能から順次実装
- 定期的なプロトタイプ検証
- 最小限の機能でMVPリリース

## 📊 進捗管理

**現在の進捗**: バックエンド基盤 100% 完了、認証機能 100% 完了
**次のタスク**: 野菜管理画面実装
**全体進捗**: 約35% 完了（基盤構築・認証フェーズ）