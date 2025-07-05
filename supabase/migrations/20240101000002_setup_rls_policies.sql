-- Row Level Security (RLS) ポリシー設定
-- ユーザーが自分のデータのみにアクセスできるようにする

-- RLS を有効化
ALTER TABLE vegetables ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_vegetables ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- vegetables テーブル（野菜マスタ）
-- 全ユーザーが読み取り可能、管理者のみが書き込み可能
CREATE POLICY "vegetables_select_policy" ON vegetables
    FOR SELECT USING (true);

-- user_vegetables テーブル
-- ユーザーは自分の栽培記録のみアクセス可能
CREATE POLICY "user_vegetables_select_policy" ON user_vegetables
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "user_vegetables_insert_policy" ON user_vegetables
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_vegetables_update_policy" ON user_vegetables
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "user_vegetables_delete_policy" ON user_vegetables
    FOR DELETE USING (auth.uid() = user_id);

-- notifications テーブル
-- ユーザーは自分の通知のみアクセス可能（user_vegetablesを通じて）
CREATE POLICY "notifications_select_policy" ON notifications
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = notifications.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "notifications_insert_policy" ON notifications
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = notifications.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "notifications_update_policy" ON notifications
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = notifications.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "notifications_delete_policy" ON notifications
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = notifications.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

-- consultations テーブル
-- ユーザーは自分のAI相談履歴のみアクセス可能
CREATE POLICY "consultations_select_policy" ON consultations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = consultations.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "consultations_insert_policy" ON consultations
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = consultations.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "consultations_update_policy" ON consultations
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = consultations.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "consultations_delete_policy" ON consultations
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = consultations.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

-- photos テーブル（フェーズ2用）
-- ユーザーは自分の写真のみアクセス可能
CREATE POLICY "photos_select_policy" ON photos
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = photos.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "photos_insert_policy" ON photos
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = photos.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "photos_update_policy" ON photos
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = photos.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );

CREATE POLICY "photos_delete_policy" ON photos
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM user_vegetables
            WHERE user_vegetables.id = photos.user_vegetable_id
            AND user_vegetables.user_id = auth.uid()
        )
    );