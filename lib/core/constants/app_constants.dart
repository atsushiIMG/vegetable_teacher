// やさいせんせい アプリ定数

class AppConstants {
  AppConstants._();

  // =====================
  // アプリ情報
  // =====================
  static const String appName = 'やさいせんせい';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.atsudev.vegetable_teacher';

  // =====================
  // API・URL関連
  // =====================
  static const String supabaseUrl = 'https://ssrfnkanoegmflgcvkpv.supabase.co';
  static const String supabaseAnonKey = ''; // 実際のキーは環境変数から設定

  // =====================
  // 野菜マスタ
  // =====================
  static const List<String> vegetableTypes = [
    'トマト',
    'きゅうり',
    'ナス',
    'オクラ',
    'バジル',
    'サニーレタス',
    '二十日大根',
    'ほうれん草',
    '小カブ',
    'ピーマン',
    'しそ',
    'モロヘイヤ',
  ];

  // =====================
  // 成長段階
  // =====================
  static const List<String> growthStages = ['発芽期', '成長期', '開花期', '収穫期'];

  // =====================
  // 作業タイプ
  // =====================
  static const List<String> taskTypes = [
    '種まき',
    '植え付け',
    '水やり',
    '間引き',
    '支柱立て',
    '追肥',
    '収穫',
  ];

  // =====================
  // 通知設定
  // =====================
  static const Duration defaultNotificationTime = Duration(hours: 8); // 朝8時
  static const Duration wateringBaseInterval = Duration(days: 2); // 基本2日間隔
  static const Duration maxNotificationDelay = Duration(days: 7); // 最大7日遅らせ可能

  // =====================
  // UI設定
  // =====================
  static const int maxRecentVegetables = 5; // 最近の野菜表示数
  static const int maxChatHistory = 50; // チャット履歴保持数
  static const Duration animationDuration = Duration(milliseconds: 300);

  // =====================
  // ローカルストレージキー
  // =====================
  static const String keyUserSettings = 'user_settings';
  static const String keyNotificationSettings = 'notification_settings';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastSyncTime = 'last_sync_time';

  // =====================
  // エラーメッセージ
  // =====================
  static const String errorNetworkUnavailable = 'ネットワークに接続できません';
  static const String errorGeneral = '予期しないエラーが発生しました';
  static const String errorAuthFailed = '認証に失敗しました';
  static const String errorDataNotFound = 'データが見つかりません';

  // =====================
  // 成功メッセージ
  // =====================
  static const String successVegetableAdded = '野菜を追加しました';
  static const String successTaskCompleted = '作業が完了しました';
  static const String successSettingsSaved = '設定を保存しました';

  // =====================
  // バリデーション
  // =====================
  static const int minPasswordLength = 8;
  static const int maxVegetableNameLength = 20;
  static const int maxChatMessageLength = 500;
}

/// 地域区分定数
class RegionalConstants {
  RegionalConstants._();

  static const Map<String, Map<String, double>> regionalFactors = {
    '寒冷地域': {'夏': 0.8, '冬': 0.5},
    '標準地域': {'夏': 1.0, '冬': 0.7},
    '温暖地域': {'夏': 1.2, '冬': 0.8},
    '亜熱帯地域': {'夏': 1.5, '冬': 1.0},
  };

  static const List<String> regions = ['寒冷地域', '標準地域', '温暖地域', '亜熱帯地域'];
}

/// フィードバック学習定数
class LearningConstants {
  LearningConstants._();

  static const double maxAdjustmentRange = 0.3; // ±30%
  static const double learningRate = 0.1; // 学習率
  static const int minFeedbackForReliability = 10; // 信頼度確立に必要なフィードバック数

  // フィードバック重み
  static const double recentWeight = 1.0; // 最新7日間
  static const double mediumWeight = 0.7; // 8-30日間
  static const double oldWeight = 0.3; // 31日以上

  // 安全上限・下限
  static const Duration minWateringInterval = Duration(hours: 12);
  static const Duration maxWateringInterval = Duration(days: 7);
  static const Duration maxScheduleAdjustment = Duration(days: 7);
}
