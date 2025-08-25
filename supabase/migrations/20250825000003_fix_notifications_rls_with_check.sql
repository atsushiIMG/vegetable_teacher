-- RLSポリシーのセキュリティ脆弱性修正
-- WITH CHECK句を追加してINSERT/UPDATE時のデータ検証を強化

-- 既存の脆弱なポリシーを削除
DROP POLICY IF EXISTS "simple_notifications_policy" ON notifications;

-- セキュアなポリシーを作成
-- USING句: SELECT/UPDATE/DELETE時のアクセス制御
-- WITH CHECK句: INSERT/UPDATE時の新規データ検証（セキュリティ強化）
CREATE POLICY "secure_notifications_policy" ON notifications
FOR ALL 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- ポリシーの説明を追加
COMMENT ON POLICY "secure_notifications_policy" ON notifications 
IS 'セキュアなuser_idベースのRLSポリシー。WITH CHECK句で他ユーザーデータの不正操作を防止';

-- RLSが有効であることを再確認
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;