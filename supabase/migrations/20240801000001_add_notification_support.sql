-- 通知設定を追加（user_profilesテーブルは既にnotification_settings JSONBカラムを持っているため、スキップ）
-- ALTER TABLE user_profiles ADD COLUMN ... は不要（notification_settings JSONBで管理）

-- 通知テーブルにSupabase専用フィールドを追加（存在しない場合のみ）
ALTER TABLE notifications
ADD COLUMN IF NOT EXISTS sent_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS vegetable_name TEXT,
ADD COLUMN IF NOT EXISTS error_message TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 通知テーブルの更新時刻を自動更新
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
CREATE TRIGGER update_notifications_updated_at 
    BEFORE UPDATE ON notifications 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 通知の種類別インデックス（存在しない場合のみ）
CREATE INDEX IF NOT EXISTS idx_notifications_task_type ON notifications(task_type);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled_date ON notifications(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_notifications_sent_at ON notifications(sent_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_vegetable_id ON notifications(user_vegetable_id);

-- ユーザープロファイルの通知設定インデックス（JSONB内のフィールド用）
CREATE INDEX IF NOT EXISTS idx_user_profiles_notification_enabled 
ON user_profiles USING GIN ((notification_settings->'notification_enabled'));