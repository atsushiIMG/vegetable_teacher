-- ストレージ設定（写真保存用バケット）
-- やさいせんせいの写真アップロード機能

-- 1. vegetable-photos バケットを作成
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES (
    'vegetable-photos',
    'vegetable-photos',
    true,
    52428800,  -- 50MB
    '{image/jpeg,image/png,image/webp,image/gif}'
);

-- 2. ストレージのRLSポリシーを設定
-- ユーザーは自分の写真のみアップロード・削除可能、全ての写真は閲覧可能

-- 写真の閲覧（全ユーザー可能）
CREATE POLICY "vegetable_photos_select_policy" ON storage.objects
    FOR SELECT USING (bucket_id = 'vegetable-photos');

-- 写真のアップロード（認証済みユーザーのみ、自分のフォルダに）
CREATE POLICY "vegetable_photos_insert_policy" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'vegetable-photos' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- 写真の更新（自分の写真のみ）
CREATE POLICY "vegetable_photos_update_policy" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'vegetable-photos' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- 写真の削除（自分の写真のみ）
CREATE POLICY "vegetable_photos_delete_policy" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'vegetable-photos' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- 3. 写真管理用のヘルパー関数

-- 写真パスを生成する関数
CREATE OR REPLACE FUNCTION generate_photo_path(
    p_user_id UUID,
    p_user_vegetable_id UUID,
    p_file_extension VARCHAR(10)
) RETURNS TEXT AS $$
BEGIN
    RETURN p_user_id::text || '/' || p_user_vegetable_id::text || '/' || 
           extract(epoch from now())::bigint || '.' || p_file_extension;
END;
$$ LANGUAGE plpgsql;

-- 写真のサムネイルURLを生成する関数
CREATE OR REPLACE FUNCTION get_photo_thumbnail_url(
    p_photo_url TEXT,
    p_width INTEGER DEFAULT 300,
    p_height INTEGER DEFAULT 300
) RETURNS TEXT AS $$
BEGIN
    -- Supabase Storageの画像変換機能を使用
    RETURN p_photo_url || '?width=' || p_width || '&height=' || p_height || '&resize=cover';
END;
$$ LANGUAGE plpgsql;

-- 4. 写真アップロード時にphotosテーブルに記録する関数
CREATE OR REPLACE FUNCTION record_photo_upload(
    p_user_vegetable_id UUID,
    p_photo_url TEXT
) RETURNS UUID AS $$
DECLARE
    v_photo_id UUID;
BEGIN
    INSERT INTO photos (user_vegetable_id, photo_url)
    VALUES (p_user_vegetable_id, p_photo_url)
    RETURNING id INTO v_photo_id;
    
    RETURN v_photo_id;
END;
$$ LANGUAGE plpgsql;

-- 5. パラパラ漫画用の写真リストを取得する関数
CREATE OR REPLACE FUNCTION get_timelapse_photos(
    p_user_vegetable_id UUID
) RETURNS TABLE (
    photo_id UUID,
    photo_url TEXT,
    thumbnail_url TEXT,
    taken_at TIMESTAMP WITH TIME ZONE,
    days_since_planted INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.photo_url,
        get_photo_thumbnail_url(p.photo_url, 150, 150) as thumbnail_url,
        p.taken_at,
        (DATE(p.taken_at) - uv.planted_date)::INTEGER as days_since_planted
    FROM photos p
    JOIN user_vegetables uv ON p.user_vegetable_id = uv.id
    WHERE p.user_vegetable_id = p_user_vegetable_id
    ORDER BY p.taken_at ASC;
END;
$$ LANGUAGE plpgsql;

-- 6. 写真の自動削除（アーカイブ後90日）
CREATE OR REPLACE FUNCTION cleanup_old_photos() RETURNS VOID AS $$
BEGIN
    -- アーカイブされた野菜の写真を90日後に削除
    DELETE FROM photos
    WHERE user_vegetable_id IN (
        SELECT id FROM user_vegetables 
        WHERE status = 'archived' 
        AND updated_at < NOW() - INTERVAL '90 days'
    );
END;
$$ LANGUAGE plpgsql;