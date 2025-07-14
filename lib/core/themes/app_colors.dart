// やさいせんせい カラーパレット定義
// Material Design 3準拠

import 'package:flutter/material.dart';

/// アプリ全体で使用するカラーパレット
class AppColors {
  AppColors._();

  // =====================
  // プライマリカラー（緑系）
  // =====================
  static const Color primary = Color(0xFF4CAF50);    // 自然・野菜・成長
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);
  
  // =====================
  // セカンダリカラー（オレンジ系）
  // =====================
  static const Color secondary = Color(0xFFFF9800);   // 太陽・元気・収穫
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);

  // =====================
  // アクセントカラー
  // =====================
  static const Color accent = Color(0xFFFFC107);      // 明るさ・注意喚起
  static const Color warning = Color(0xFFFF5722);     // 警告
  static const Color success = Color(0xFF4CAF50);     // 成功（プライマリと同じ）
  static const Color info = Color(0xFF2196F3);        // 情報
  static const Color error = Color(0xFFE91E63);       // エラー

  // =====================
  // ニュートラルカラー
  // =====================
  static const Color background = Color(0xFFFAFAFA);  // 背景
  static const Color surface = Color(0xFFFFFFFF);     // サーフェス
  static const Color onSurface = Color(0xFF333333);   // サーフェス上のテキスト
  static const Color onBackground = Color(0xFF424242); // 背景上のテキスト
  static const Color disabled = Color(0xFF9E9E9E);    // 無効状態
  static const Color divider = Color(0xFFE0E0E0);     // 境界線

  // =====================
  // 野菜固有カラー
  // =====================
  static const Color tomato = Color(0xFFFF6B6B);      // トマト
  static const Color cucumber = Color(0xFF2ECC71);     // きゅうり
  static const Color eggplant = Color(0xFF8E44AD);     // ナス
  static const Color okra = Color(0xFF27AE60);         // オクラ
  static const Color basil = Color(0xFF2ECC71);        // バジル
  static const Color lettuce = Color(0xFF2ECC71);      // サニーレタス
  static const Color radish = Color(0xFFE74C3C);       // 二十日大根
  static const Color spinach = Color(0xFF1E8449);      // ほうれん草
  static const Color turnip = Color(0xFFFFFFFF);       // 小カブ
  static const Color pepper = Color(0xFF2ECC71);       // ピーマン
  static const Color shiso = Color(0xFF8E44AD);        // しそ
  static const Color moroheiya = Color(0xFF2ECC71);    // モロヘイヤ

  // =====================
  // 成長段階カラー
  // =====================
  static const Color seedling = Color(0xFFF1C40F);     // 発芽期（黄色）
  static const Color growing = Color(0xFF4CAF50);      // 成長期（緑色）
  static const Color flowering = Color(0xFFFF9800);    // 開花期（オレンジ）
  static const Color harvesting = Color(0xFFF44336);   // 収穫期（赤色）

  // =====================
  // 作業優先度カラー
  // =====================
  static const Color urgent = Color(0xFFFF5722);       // 緊急（赤）
  static const Color important = Color(0xFFFF9800);    // 重要（オレンジ）
  static const Color normal = Color(0xFF4CAF50);       // 通常（緑）
  static const Color completed = Color(0xFF9E9E9E);    // 完了（グレー）

  // =====================
  // 機能別カラー
  // =====================
  static const Color watering = Color(0xFF3498DB);     // 水やり（青）
  static const Color pruning = Color(0xFF95A5A6);      // 間引き（グレー）
  static const Color harvestingIcon = Color(0xFFF39C12); // 収穫アイコン（黄色）
  static const Color aiAvatar = Color(0xFF3498DB);     // AIアバター（青）
  static const Color notification = Color(0xFFF39C12); // 通知（黄色）

  /// 野菜IDから対応する色を取得
  static Color getVegetableColor(String vegetableId) {
    switch (vegetableId.toLowerCase()) {
      case 'tomato':
      case 'トマト':
        return tomato;
      case 'cucumber':
      case 'きゅうり':
        return cucumber;
      case 'eggplant':
      case 'ナス':
        return eggplant;
      case 'okra':
      case 'オクラ':
        return okra;
      case 'basil':
      case 'バジル':
        return basil;
      case 'lettuce':
      case 'サニーレタス':
        return lettuce;
      case 'radish':
      case '二十日大根':
        return radish;
      case 'spinach':
      case 'ほうれん草':
        return spinach;
      case 'turnip':
      case '小カブ':
        return turnip;
      case 'pepper':
      case 'ピーマン':
        return pepper;
      case 'shiso':
      case 'しそ':
        return shiso;
      case 'moroheiya':
      case 'モロヘイヤ':
        return moroheiya;
      default:
        return primary; // デフォルトは緑
    }
  }

  /// 成長段階から対応する色を取得
  static Color getGrowthStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'seedling':
      case '発芽期':
      case '種まき':
        return seedling;
      case 'growing':
      case '成長期':
        return growing;
      case 'flowering':
      case '開花期':
        return flowering;
      case 'harvesting':
      case '収穫期':
        return harvesting;
      default:
        return growing; // デフォルトは成長期
    }
  }

  /// 作業優先度から対応する色を取得
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case '緊急':
        return urgent;
      case 'important':
      case '重要':
        return important;
      case 'normal':
      case '通常':
        return normal;
      case 'completed':
      case '完了':
        return completed;
      default:
        return normal; // デフォルトは通常
    }
  }
}

/// Material Design 3 カラーシード
class AppColorScheme {
  static const Color _primarySeed = Color(0xFF4CAF50);

  /// ライトテーマのカラースキーム
  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
    ).copyWith(
      // カスタムカラーの上書き
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
    );
  }

  /// ダークテーマのカラースキーム（将来の拡張用）
  static ColorScheme get darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
    );
  }
}