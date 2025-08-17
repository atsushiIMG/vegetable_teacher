-- 未使用の通知関連SQL関数を削除
-- Edge Functionsで代替実装済みのため不要

-- 1. 水やり通知一括生成関数を削除
DROP FUNCTION IF EXISTS generate_watering_notifications(UUID, INTEGER, DECIMAL);

-- 2. 通知スケジュール計算関数を削除  
DROP FUNCTION IF EXISTS calculate_notification_schedule(UUID, DATE, JSONB);

-- ログ出力（削除完了の記録）
DO $$
BEGIN
    RAISE NOTICE 'Unused notification functions cleaned up successfully';
END $$;