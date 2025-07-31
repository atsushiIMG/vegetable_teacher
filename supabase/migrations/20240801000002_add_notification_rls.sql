-- 通知テーブルのRLS設定

-- RLSを有効化
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分の通知のみを閲覧可能
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_vegetables uv
            WHERE uv.id = notifications.user_vegetable_id 
            AND uv.user_id = auth.uid()
        )
    );

-- ユーザーは自分の通知のみを更新可能（フィードバック用）
CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables uv
            WHERE uv.id = notifications.user_vegetable_id 
            AND uv.user_id = auth.uid()
        )
    );

-- サービスロールは全ての通知を操作可能（Edge Functions用）
CREATE POLICY "Service role can manage all notifications" ON notifications
    FOR ALL USING (
        current_setting('role') = 'service_role'
    );

-- 通知作成は認証済みユーザーまたはサービスロールが可能
CREATE POLICY "Authenticated users and service role can insert notifications" ON notifications
    FOR INSERT WITH CHECK (
        auth.role() = 'authenticated' OR current_setting('role') = 'service_role'
    );

-- プロファイルテーブルの通知設定に対するRLS
-- （既存のプロファイルRLSがあると仮定）

-- リアルタイム購読用の権限設定
-- ユーザーは自分の通知チャンネルのみ購読可能
CREATE OR REPLACE FUNCTION can_subscribe_to_notifications(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 通知テーブルでのリアルタイム購読を許可
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT SELECT ON notifications TO authenticated;

-- Realtimeの設定（publication作成）
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE notifications;
COMMIT;