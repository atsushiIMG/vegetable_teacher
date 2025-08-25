-- RLS問題切り分けテスト: notificationsテーブルのRLSを一時無効化
-- これはテスト目的で、後で再有効化します

-- RLSを無効化
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- テスト用コメント
-- この後 send-push-notifications でRealtimeイベントが受信できるかテスト
-- 受信できればRLSが原因と確定される