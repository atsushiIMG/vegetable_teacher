-- 家庭菜園管理アプリ - 初期テーブル作成
-- Created: 2024-01-01

-- 1. vegetables テーブル（野菜マスタ）
CREATE TABLE vegetables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    schedule JSONB NOT NULL,
    growing_tips TEXT,
    common_problems TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. user_vegetables テーブル（ユーザーの栽培記録）
CREATE TABLE user_vegetables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vegetable_id UUID NOT NULL REFERENCES vegetables(id) ON DELETE CASCADE,
    planted_date DATE NOT NULL,
    plant_type VARCHAR(10) NOT NULL CHECK (plant_type IN ('種', '苗')),
    location VARCHAR(10) NOT NULL CHECK (location IN ('鉢', '畑')),
    is_photo_mode BOOLEAN DEFAULT FALSE,
    photo_id VARCHAR(50),
    status VARCHAR(20) DEFAULT 'growing' CHECK (status IN ('growing', 'harvested', 'archived')),
    schedule_adjustments JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. notifications テーブル（通知履歴）
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_vegetable_id UUID NOT NULL REFERENCES user_vegetables(id) ON DELETE CASCADE,
    task_type VARCHAR(50) NOT NULL,
    scheduled_date DATE NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE,
    feedback JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. consultations テーブル（AI相談履歴）
CREATE TABLE consultations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_vegetable_id UUID NOT NULL REFERENCES user_vegetables(id) ON DELETE CASCADE,
    messages JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. photos テーブル（写真記録）※フェーズ2用
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_vegetable_id UUID NOT NULL REFERENCES user_vegetables(id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    taken_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成
CREATE INDEX idx_user_vegetables_user_id ON user_vegetables(user_id);
CREATE INDEX idx_user_vegetables_vegetable_id ON user_vegetables(vegetable_id);
CREATE INDEX idx_user_vegetables_status ON user_vegetables(status);
CREATE INDEX idx_notifications_user_vegetable_id ON notifications(user_vegetable_id);
CREATE INDEX idx_notifications_scheduled_date ON notifications(scheduled_date);
CREATE INDEX idx_consultations_user_vegetable_id ON consultations(user_vegetable_id);
CREATE INDEX idx_photos_user_vegetable_id ON photos(user_vegetable_id);
CREATE INDEX idx_photos_taken_at ON photos(taken_at);

-- 更新時刻の自動更新用トリガー関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 各テーブルに更新時刻の自動更新トリガーを設定
CREATE TRIGGER update_vegetables_updated_at
    BEFORE UPDATE ON vegetables
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_vegetables_updated_at
    BEFORE UPDATE ON user_vegetables
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultations_updated_at
    BEFORE UPDATE ON consultations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();