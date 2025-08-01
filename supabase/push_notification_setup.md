# Supabaseプッシュ通知機能セットアップガイド

## 概要
やさいせんせいアプリのSupabaseリアルタイム通知機能の設定方法と使用方法について説明します。
Firebaseを使わず、Supabaseの機能のみで通知を実現します。

## Supabase設定

### 1. 環境変数設定
特別な外部サービスのAPIキーは不要です。Supabaseの機能のみを使用します。

### 2. データベースマイグレーション実行
```bash
supabase db push
```

### 3. Functions デプロイ
```bash
# 通知スケジュール管理
supabase functions deploy notification-scheduler

# プッシュ通知送信
supabase functions deploy send-push-notifications

# 定期実行用cronジョブ
supabase functions deploy notification-cron
```

### 4. 定期実行設定
Supabase Dashboard → Edge Functions → Cron Jobs で以下を設定：

```
0 9 * * * notification-cron  # 毎日9時に実行
```

## 通知の仕組み

### 1. 通知スケジュール計算
`notification-scheduler` Functionが以下を計算：
- 各野菜の栽培日数に基づく作業タスク
- 種・苗の違いを考慮したスケジュール調整
- 季節係数を適用した水やり頻度
- ユーザー個別の調整設定

### 2. 通知送信処理
`send-push-notifications` Functionが：
- 当日の通知をデータベースから取得
- ユーザーの通知設定を確認
- `sent_at`を更新してリアルタイム通知を発火
- クライアント側でローカル通知として表示

### 3. 定期実行
- 毎日9時に `notification-cron` が実行
- スケジュール計算 → 通知送信の流れを自動実行

## Flutter側の設定

### 1. 依存関係
```yaml
dependencies:
  flutter_local_notifications: ^17.2.3
  supabase_flutter: ^2.5.6
```

### 2. 権限設定
`android/app/src/main/AndroidManifest.xml`：
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### 3. Supabase設定
- `.env`ファイルでSupabase URLとAnon Keyを設定
- リアルタイム機能が有効になっていることを確認

## 使用方法

### 1. アプリ起動時の初期化
```dart
await SupabaseNotificationService().initialize();
```

### 2. 通知設定の変更
```dart
await SupabaseNotificationService().updateNotificationSettings(
  enabled: true,
  notificationTime: TimeOfDay(hour: 9, minute: 0),
  weekendNotifications: true,
);
```

### 3. テスト通知
```dart
await SupabaseNotificationService().sendTestNotification();
```

### 4. 手動通知チェック
```dart
await SupabaseNotificationService().checkPendingNotifications();
```

## トラブルシューティング

### 通知が届かない場合
1. `notification_enabled` がtrueに設定されているか確認
2. Supabaseリアルタイム機能が有効になっているか確認
3. Android端末で通知権限が許可されているか確認
4. インターネット接続が安定しているか確認

### デバッグ方法
1. Supabase Functions のログを確認
2. Supabase Dashboard のRealtime機能が有効か確認
3. 通知テーブルにデータが正しく挿入されているか確認
4. クライアント側でリアルタイムチャンネルが正しく購読されているか確認

## セキュリティ考慮事項

### 1. データベースセキュリティ
- 外部APIキーは不要
- Supabaseの認証機能のみを使用

### 2. 通知内容の制限
- 個人情報を含む内容は送信しない
- 野菜の種類と作業内容のみ通知

### 3. RLS (Row Level Security)
- 各テーブルでユーザー別のアクセス制御
- 他ユーザーの通知設定にアクセス不可
- リアルタイム購読も適切に制限

## パフォーマンス最適化

### 1. 通知頻度の調整
- 水やり通知は季節係数で自動調整
- ユーザーフィードバックに基づく個別調整

### 2. バッチ処理
- 1日1回の定期実行でまとめて処理
- 複数ユーザーの通知を効率的に送信

### 3. エラーハンドリング
- リアルタイム接続失敗時の再接続機能
- 通知送信失敗時のログ記録