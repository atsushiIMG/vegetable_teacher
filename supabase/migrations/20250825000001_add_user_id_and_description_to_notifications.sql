-- notifications テーブルに user_id と description 列を追加
-- 通知システムの最適化: RLSポリシー簡素化とローカル通知表示用

-- user_id 列を追加（既存のauth.usersテーブルを参照）
ALTER TABLE notifications 
ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- description 列を追加（通知本文用）
ALTER TABLE notifications 
ADD COLUMN description TEXT;

-- 既存レコードの user_id を設定
UPDATE notifications 
SET user_id = (
  SELECT uv.user_id 
  FROM user_vegetables uv 
  WHERE uv.id = notifications.user_vegetable_id
)
WHERE user_id IS NULL;

-- user_id にインデックス作成（RLSパフォーマンス向上）
CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON notifications(user_id);

-- コメント
COMMENT ON COLUMN notifications.user_id IS '通知の対象ユーザー（RLSポリシー簡素化用）';
COMMENT ON COLUMN notifications.description IS 'ローカル通知で表示する本文';