-- 認証設定とユーザープロファイル拡張
-- Supabase Authの設定とユーザー情報の管理

-- 1. ユーザープロファイルテーブル（auth.usersの拡張）
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    location VARCHAR(100),
    experience_level VARCHAR(20) DEFAULT 'beginner' CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
    notification_settings JSONB DEFAULT '{
        "watering_reminders": true,
        "task_reminders": true,
        "harvest_reminders": true,
        "general_tips": true
    }',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. RLS有効化とポリシー設定
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分のプロファイルのみアクセス可能
CREATE POLICY "user_profiles_select_policy" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "user_profiles_insert_policy" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "user_profiles_update_policy" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "user_profiles_delete_policy" ON user_profiles
    FOR DELETE USING (auth.uid() = id);

-- 3. 新規ユーザー登録時の自動プロファイル作成
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
    -- 入力検証
    IF NEW.id IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null';
    END IF;
    
    IF NEW.email IS NULL OR NEW.email = '' THEN
        RAISE EXCEPTION 'User email cannot be null or empty';
    END IF;
    
    -- プロファイル作成
    INSERT INTO public.user_profiles (id, display_name)
    VALUES (
        NEW.id, 
        COALESCE(
            NEW.raw_user_meta_data->>'display_name', 
            split_part(NEW.email, '@', 1)
        )
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- TODO エラーログを記録（本番環境では適切なログシステムを使用）
        RAISE EXCEPTION 'Failed to create user profile: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 新規ユーザー作成時にプロファイルを自動作成
CREATE TRIGGER create_user_profile_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile();

-- 4. プロファイル更新時刻の自動更新
-- 依存関数の定義（他のマイグレーションで定義済みの場合は無視される）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 5. 認証関連のヘルパー関数

-- ユーザーの経験レベルを更新する関数
CREATE OR REPLACE FUNCTION update_user_experience_level(
    p_user_id UUID,
    p_experience_level VARCHAR(20)
) RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- 入力検証
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null';
    END IF;
    
    IF p_experience_level NOT IN ('beginner', 'intermediate', 'advanced') THEN
        RAISE EXCEPTION 'Invalid experience level: %', p_experience_level;
    END IF;
    
    -- 権限チェック（現在のユーザーが自分のプロファイルを更新しているか）
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Permission denied: cannot update other users profile';
    END IF;
    
    UPDATE public.user_profiles
    SET experience_level = p_experience_level
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- 通知設定を更新する関数
CREATE OR REPLACE FUNCTION update_notification_settings(
    p_user_id UUID,
    p_settings JSONB
) RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- 入力検証
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null';
    END IF;
    
    IF p_settings IS NULL THEN
        RAISE EXCEPTION 'Settings cannot be null';
    END IF;
    
    -- 権限チェック（現在のユーザーが自分のプロファイルを更新しているか）
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Permission denied: cannot update other users profile';
    END IF;
    
    UPDATE public.user_profiles
    SET notification_settings = p_settings
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ユーザーの通知設定を取得する関数
CREATE OR REPLACE FUNCTION get_user_notification_settings(
    p_user_id UUID
) RETURNS JSONB
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_settings JSONB;
BEGIN
    -- 入力検証
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null';
    END IF;
    
    -- 権限チェック（現在のユーザーが自分のプロファイルを取得しているか）
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Permission denied: cannot access other users profile';
    END IF;
    
    SELECT notification_settings INTO v_settings
    FROM public.user_profiles
    WHERE id = p_user_id;
    
    RETURN COALESCE(v_settings, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- 6. ユーザー統計情報ビュー
CREATE VIEW user_stats AS
SELECT 
    up.id,
    up.display_name,
    up.experience_level,
    COUNT(uv.id) as total_vegetables,
    COUNT(CASE WHEN uv.status = 'growing' THEN 1 END) as growing_vegetables,
    COUNT(CASE WHEN uv.status = 'harvested' THEN 1 END) as harvested_vegetables,
    COUNT(DISTINCT uv.vegetable_id) as unique_vegetable_types,
    (
        SELECT COUNT(*)
        FROM notifications n
        JOIN user_vegetables uv2 ON n.user_vegetable_id = uv2.id
        WHERE uv2.user_id = up.id
        AND n.feedback IS NOT NULL
    ) as completed_tasks,
    (
        SELECT COUNT(*)
        FROM photos p
        JOIN user_vegetables uv3 ON p.user_vegetable_id = uv3.id
        WHERE uv3.user_id = up.id
    ) as total_photos,
    MIN(uv.created_at) as first_planting_date,
    MAX(uv.created_at) as last_planting_date
FROM user_profiles up
LEFT JOIN user_vegetables uv ON up.id = uv.user_id
GROUP BY up.id, up.display_name, up.experience_level;

-- 7. アカウント削除時のデータクリーンアップ
CREATE OR REPLACE FUNCTION cleanup_user_data()
RETURNS TRIGGER AS $$
BEGIN
    -- ユーザーの写真をStorageから削除（この関数は実際にはSupabase Functionsで実装）
    -- 関連データは外部キー制約により自動削除される
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_user_data_trigger
    BEFORE DELETE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION cleanup_user_data();

-- 8. メール認証設定の調整
-- クラウド版Supabaseでは、認証設定はWeb UIから行う必要があります
-- Authentication > Settings で以下の設定を手動で行ってください:
-- - Site Name: やさいせんせい
-- - Secure email change: enabled
-- - Confirm email: enabled
-- - Captcha: disabled (開発時)