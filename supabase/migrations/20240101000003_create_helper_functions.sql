-- ヘルパー関数とビューの作成
-- 通知スケジュールの計算や統計情報の取得などの便利機能

-- 1. 通知スケジュールを計算する関数
CREATE OR REPLACE FUNCTION calculate_notification_schedule(
    p_user_vegetable_id UUID,
    p_planted_date DATE,
    p_vegetable_schedule JSONB
) RETURNS TABLE (
    task_type VARCHAR(50),
    scheduled_date DATE,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (task->>'type')::VARCHAR(50) as task_type,
        (p_planted_date + (task->>'day')::INTEGER)::DATE as scheduled_date,
        (task->>'description')::TEXT as description
    FROM jsonb_array_elements(p_vegetable_schedule->'tasks') as task;
END;
$$ LANGUAGE plpgsql;

-- 2. ユーザーの栽培統計を取得するビュー
CREATE VIEW user_vegetable_stats AS
SELECT 
    uv.user_id,
    v.name as vegetable_name,
    COUNT(*) as total_plantings,
    COUNT(CASE WHEN uv.status = 'growing' THEN 1 END) as growing_count,
    COUNT(CASE WHEN uv.status = 'harvested' THEN 1 END) as harvested_count,
    COUNT(CASE WHEN uv.status = 'archived' THEN 1 END) as archived_count,
    MIN(uv.planted_date) as first_planted,
    MAX(uv.planted_date) as last_planted
FROM user_vegetables uv
JOIN vegetables v ON uv.vegetable_id = v.id
GROUP BY uv.user_id, v.name;

-- 3. 今日の作業予定を取得する関数
CREATE OR REPLACE FUNCTION get_today_tasks(p_user_id UUID)
RETURNS TABLE (
    user_vegetable_id UUID,
    vegetable_name VARCHAR(100),
    task_type VARCHAR(50),
    scheduled_date DATE,
    photo_id VARCHAR(50),
    days_since_planted INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uv.id as user_vegetable_id,
        v.name as vegetable_name,
        n.task_type,
        n.scheduled_date,
        uv.photo_id,
        (CURRENT_DATE - uv.planted_date)::INTEGER as days_since_planted
    FROM user_vegetables uv
    JOIN vegetables v ON uv.vegetable_id = v.id
    JOIN notifications n ON uv.id = n.user_vegetable_id
    WHERE uv.user_id = p_user_id
    AND uv.status = 'growing'
    AND n.scheduled_date = CURRENT_DATE
    AND n.sent_at IS NULL
    ORDER BY n.scheduled_date, v.name;
END;
$$ LANGUAGE plpgsql;

-- 4. 水やり通知を生成する関数
CREATE OR REPLACE FUNCTION generate_watering_notifications(
    p_user_vegetable_id UUID,
    p_base_interval INTEGER,
    p_season_factor DECIMAL DEFAULT 1.0
) RETURNS VOID AS $$
DECLARE
    v_planted_date DATE;
    v_current_date DATE;
    v_watering_interval INTEGER;
    v_next_watering_date DATE;
BEGIN
    -- 植えた日を取得
    SELECT planted_date INTO v_planted_date
    FROM user_vegetables
    WHERE id = p_user_vegetable_id;
    
    -- 季節係数を考慮した水やり間隔を計算
    v_watering_interval := ROUND(p_base_interval * p_season_factor);
    
    -- 現在日から90日後まで水やり通知を生成
    v_current_date := GREATEST(CURRENT_DATE, v_planted_date);
    v_next_watering_date := v_current_date + v_watering_interval;
    
    WHILE v_next_watering_date <= CURRENT_DATE + INTERVAL '90 days' LOOP
        -- 水やり通知を作成
        INSERT INTO notifications (user_vegetable_id, task_type, scheduled_date)
        VALUES (p_user_vegetable_id, '水やり', v_next_watering_date);
        
        -- 次の水やり日を計算
        v_next_watering_date := v_next_watering_date + v_watering_interval;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 5. ユーザー野菜の詳細情報を取得するビュー
CREATE VIEW user_vegetable_details AS
SELECT 
    uv.id,
    uv.user_id,
    v.name as vegetable_name,
    uv.planted_date,
    uv.plant_type,
    uv.location,
    uv.is_photo_mode,
    uv.photo_id,
    uv.status,
    (CURRENT_DATE - uv.planted_date)::INTEGER as days_since_planted,
    v.schedule,
    v.growing_tips,
    v.common_problems,
    (
        SELECT COUNT(*)
        FROM notifications
        WHERE user_vegetable_id = uv.id
        AND sent_at IS NOT NULL
    ) as completed_notifications,
    (
        SELECT COUNT(*)
        FROM consultations
        WHERE user_vegetable_id = uv.id
    ) as consultation_count,
    (
        SELECT COUNT(*)
        FROM photos
        WHERE user_vegetable_id = uv.id
    ) as photo_count
FROM user_vegetables uv
JOIN vegetables v ON uv.vegetable_id = v.id;