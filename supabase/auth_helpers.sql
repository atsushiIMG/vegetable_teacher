-- 認証関連のヘルパー関数とビュー
-- 開発・テスト用のデータ操作関数

-- 1. テストユーザー作成関数（開発用）
CREATE OR REPLACE FUNCTION create_test_user(
    p_email TEXT,
    p_password TEXT,
    p_display_name TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- 本番環境では使用しないよう警告
    IF current_setting('app.environment', true) = 'production' THEN
        RAISE EXCEPTION 'テストユーザー作成は本番環境では実行できません';
    END IF;

    -- UUIDを生成
    v_user_id := gen_random_uuid();

    -- auth.usersテーブルに直接挿入（開発用）
    INSERT INTO auth.users (
        id,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        raw_user_meta_data
    ) VALUES (
        v_user_id,
        p_email,
        crypt(p_password, gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        jsonb_build_object('display_name', COALESCE(p_display_name, split_part(p_email, '@', 1)))
    );

    -- プロファイルは自動作成トリガーで作成される

    RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- 2. ユーザー削除関数（開発用）
CREATE OR REPLACE FUNCTION delete_test_user(
    p_email TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- 本番環境では使用しないよう警告
    IF current_setting('app.environment', true) = 'production' THEN
        RAISE EXCEPTION 'テストユーザー削除は本番環境では実行できません';
    END IF;

    -- ユーザーIDを取得
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE email = p_email;

    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- ユーザーを削除（関連データも CASCADE で削除）
    DELETE FROM auth.users WHERE id = v_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 3. パスワード強度チェック関数
CREATE OR REPLACE FUNCTION check_password_strength(
    p_password TEXT
) RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_has_lowercase BOOLEAN;
    v_has_uppercase BOOLEAN;
    v_has_numbers BOOLEAN;
    v_has_symbols BOOLEAN;
    v_length_ok BOOLEAN;
    v_score INTEGER;
BEGIN
    -- 各条件をチェック
    v_has_lowercase := p_password ~ '[a-z]';
    v_has_uppercase := p_password ~ '[A-Z]';
    v_has_numbers := p_password ~ '[0-9]';
    v_has_symbols := p_password ~ '[^a-zA-Z0-9]';
    v_length_ok := length(p_password) >= 8;

    -- スコア計算
    v_score := 0;
    IF v_length_ok THEN v_score := v_score + 1; END IF;
    IF v_has_lowercase THEN v_score := v_score + 1; END IF;
    IF v_has_uppercase THEN v_score := v_score + 1; END IF;
    IF v_has_numbers THEN v_score := v_score + 1; END IF;
    IF v_has_symbols THEN v_score := v_score + 1; END IF;

    -- 結果を作成
    v_result := jsonb_build_object(
        'score', v_score,
        'max_score', 5,
        'is_strong', v_score >= 3,
        'checks', jsonb_build_object(
            'length', v_length_ok,
            'lowercase', v_has_lowercase,
            'uppercase', v_has_uppercase,
            'numbers', v_has_numbers,
            'symbols', v_has_symbols
        ),
        'strength', CASE 
            WHEN v_score <= 2 THEN 'weak'
            WHEN v_score = 3 THEN 'medium'
            WHEN v_score = 4 THEN 'strong'
            ELSE 'very_strong'
        END
    );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- 4. アクティブユーザー統計ビュー
CREATE VIEW active_users_stats AS
SELECT
    COUNT(*) as total_users,
    COUNT(CASE WHEN last_sign_in_at > NOW() - INTERVAL '24 hours' THEN 1 END) as daily_active,
    COUNT(CASE WHEN last_sign_in_at > NOW() - INTERVAL '7 days' THEN 1 END) as weekly_active,
    COUNT(CASE WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 1 END) as monthly_active,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '24 hours' THEN 1 END) as new_today,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as new_this_week
FROM auth.users
WHERE deleted_at IS NULL;

-- 5. ユーザー詳細情報ビュー
CREATE VIEW user_details AS
SELECT
    u.id,
    u.email,
    u.created_at as registered_at,
    u.last_sign_in_at,
    u.email_confirmed_at,
    up.display_name,
    up.location,
    up.experience_level,
    up.notification_settings,
    us.total_vegetables,
    us.growing_vegetables,
    us.harvested_vegetables,
    us.completed_tasks,
    us.total_photos
FROM auth.users u
LEFT JOIN user_profiles up ON u.id = up.id
LEFT JOIN user_stats us ON u.id = us.id
WHERE u.deleted_at IS NULL;

-- 6. 認証ログ関数（セキュリティ監査用）
CREATE TABLE auth_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    action VARCHAR(50) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN DEFAULT true,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS有効化
ALTER TABLE auth_logs ENABLE ROW LEVEL SECURITY;

-- 管理者のみアクセス可能
CREATE POLICY "auth_logs_admin_only" ON auth_logs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND (notification_settings->>'admin_role')::boolean = true
        )
    );

-- 認証ログ記録関数
CREATE OR REPLACE FUNCTION log_auth_event(
    p_user_id UUID,
    p_action VARCHAR(50),
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_success BOOLEAN DEFAULT TRUE,
    p_details JSONB DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO auth_logs (user_id, action, ip_address, user_agent, success, details)
    VALUES (p_user_id, p_action, p_ip_address, p_user_agent, p_success, p_details);
END;
$$ LANGUAGE plpgsql;

-- 7. セッション管理関数
CREATE OR REPLACE FUNCTION cleanup_expired_sessions() RETURNS VOID AS $$
BEGIN
    -- 期限切れのセッションをクリーンアップ
    DELETE FROM auth.sessions 
    WHERE expires_at < NOW();
    
    -- 古いリフレッシュトークンを削除
    DELETE FROM auth.refresh_tokens 
    WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- 8. アカウント状態確認関数
CREATE OR REPLACE FUNCTION get_account_status(
    p_user_id UUID
) RETURNS JSONB AS $$
DECLARE
    v_user auth.users%ROWTYPE;
    v_profile user_profiles%ROWTYPE;
    v_result JSONB;
BEGIN
    -- ユーザー情報を取得
    SELECT * INTO v_user FROM auth.users WHERE id = p_user_id;
    SELECT * INTO v_profile FROM user_profiles WHERE id = p_user_id;

    IF v_user IS NULL THEN
        RETURN jsonb_build_object('error', 'ユーザーが見つかりません');
    END IF;

    -- アカウント状態を作成
    v_result := jsonb_build_object(
        'user_id', v_user.id,
        'email', v_user.email,
        'email_confirmed', v_user.email_confirmed_at IS NOT NULL,
        'phone_confirmed', v_user.phone_confirmed_at IS NOT NULL,
        'last_sign_in', v_user.last_sign_in_at,
        'created_at', v_user.created_at,
        'is_active', v_user.deleted_at IS NULL,
        'profile_complete', v_profile.display_name IS NOT NULL,
        'experience_level', v_profile.experience_level,
        'notification_settings', v_profile.notification_settings
    );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;