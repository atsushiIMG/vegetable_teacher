// やさいせんせい メインテーマ設定
// Material Design 3準拠

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// アプリ全体のテーマ設定
class AppTheme {
  AppTheme._();

  // =====================
  // ライトテーマ
  // =====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.lightColorScheme,
      textTheme: AppTextStyles.textTheme,
      
      // =====================
      // AppBar テーマ
      // =====================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.primaryFontFamily,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),

      // =====================
      // Card テーマ
      // =====================
      cardTheme: const CardTheme(
        color: AppColors.surface,
        shadowColor: AppColors.divider,
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // =====================
      // Button テーマ
      // =====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(88, 48),
        ),
      ),

      // =====================
      // FloatingActionButton テーマ
      // =====================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // =====================
      // InputDecoration テーマ
      // =====================
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.body2,
        hintStyle: TextStyle(
          color: AppColors.disabled,
          fontSize: 16,
          fontFamily: AppTextStyles.primaryFontFamily,
        ),
      ),

      // =====================
      // その他の設定
      // =====================
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,
      disabledColor: AppColors.disabled,
      dividerColor: AppColors.divider,
      
      // スプラッシュカラー
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
    );
  }

  // =====================
  // ダークテーマ（将来の拡張用）
  // =====================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.darkColorScheme,
      textTheme: AppTextStyles.textTheme,
      // ダークテーマの詳細設定は将来実装
    );
  }
}

/// カスタムウィジェット用のテーマクラス
class CustomTheme {
  CustomTheme._();

  // =====================
  // 野菜カードのスタイル
  // =====================
  static BoxDecoration get vegetableCardDecoration {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.divider.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // =====================
  // AI チャットバブルのスタイル
  // =====================
  static BoxDecoration get userChatBubble {
    return const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      ),
    );
  }

  static BoxDecoration get aiChatBubble {
    return const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(16),
      ),
    );
  }

  // =====================
  // 通知バッジのスタイル
  // =====================
  static BoxDecoration get notificationBadge {
    return BoxDecoration(
      color: AppColors.warning,
      borderRadius: BorderRadius.circular(10),
    );
  }
}

/// UI定数値
class UIConstants {
  UIConstants._();

  // =====================
  // スペーシング
  // =====================
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // =====================
  // 角丸
  // =====================
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;

  // =====================
  // アイコンサイズ
  // =====================
  static const double iconXS = 16.0;
  static const double iconS = 24.0;
  static const double iconM = 32.0;
  static const double iconL = 48.0;
  static const double iconXL = 64.0;
}