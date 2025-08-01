-- 通知設定を追加
ALTER TABLE profiles 
ADD COLUMN notification_enabled BOOLEAN DEFAULT true,
ADD COLUMN notification_time TIME DEFAULT '09:00:00',
ADD COLUMN weekend_notifications BOOLEAN DEFAULT true;

-- 通知テーブルにSupabase専用フィールドを追加
ALTER TABLE notifications
ADD COLUMN sent_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN vegetable_name TEXT,
ADD COLUMN error_message TEXT,
ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 通知テーブルの更新時刻を自動更新
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_notifications_updated_at 
    BEFORE UPDATE ON notifications 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 通知の種類別インデックス
CREATE INDEX idx_notifications_task_type ON notifications(task_type);
CREATE INDEX idx_notifications_scheduled_date ON notifications(scheduled_date);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);
CREATE INDEX idx_notifications_user_vegetable_id ON notifications(user_vegetable_id);

-- プロファイルの通知設定インデックス
CREATE INDEX idx_profiles_notification_enabled ON profiles(notification_enabled) WHERE notification_enabled = true;