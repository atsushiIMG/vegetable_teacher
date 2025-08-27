-- RLSポリシーをシンプル化
-- 複雑なJOINクエリのポリシーを削除して、user_idベースのシンプルなポリシーに置き換え

-- 既存の複雑なポリシーをすべて削除
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
DROP POLICY IF EXISTS "notifications_select_policy" ON notifications;
DROP POLICY IF EXISTS "notifications_update_policy" ON notifications;
DROP POLICY IF EXISTS "notifications_delete_policy" ON notifications;
DROP POLICY IF EXISTS "notifications_insert_policy" ON notifications;

-- シンプルなuser_idベースのポリシーを作成
CREATE POLICY "simple_notifications_policy" ON notifications
FOR ALL USING (user_id = auth.uid());

-- RLSを再有効化（テストで無効化していたため）
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- コメント
COMMENT ON POLICY "simple_notifications_policy" ON notifications 
IS 'シンプルなuser_idベースのRLSポリシー。パフォーマンスとRealtimeの相性を改善';