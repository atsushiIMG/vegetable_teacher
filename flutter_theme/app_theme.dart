// やさいせんせい メインテーマ設定
// Material Design 3準拠

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

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
      // BottomNavigationBar テーマ
      // =====================
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.disabled,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.primaryFontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: AppTextStyles.primaryFontFamily,
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
      // Chip テーマ
      // =====================
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.disabled,
        labelStyle: AppTextStyles.caption,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // =====================
      // Dialog テーマ
      // =====================
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: AppTextStyles.headline3,
        contentTextStyle: AppTextStyles.body1,
      ),

      // =====================
      // SnackBar テーマ
      // =====================
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: TextStyle(
          color: AppColors.surface,
          fontSize: 14,
          fontFamily: AppTextStyles.primaryFontFamily,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // =====================
      // ProgressIndicator テーマ
      // =====================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.divider,
        circularTrackColor: AppColors.divider,
      ),

      // =====================
      // Switch テーマ
      // =====================
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.disabled;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return AppColors.divider;
        }),
      ),

      // =====================
      // Divider テーマ
      // =====================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // =====================
      // Icon テーマ
      // =====================
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
        size: 24,
      ),

      // =====================
      // その他の設定
      // =====================
      scaffoldBackgroundColor: AppColors.background,
      backgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,
      accentColor: AppColors.secondary,
      errorColor: AppColors.error,
      disabledColor: AppColors.disabled,
      dividerColor: AppColors.divider,
      
      // スプラッシュカラー
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
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
          color: AppColors.divider.withOpacity(0.3),
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
    return BoxDecoration(
      color: AppColors.primary,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      ),
    );
  }

  static BoxDecoration get aiChatBubble {
    return BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.divider),
      borderRadius: const BorderRadius.only(
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

  // =====================
  // 成長段階インジケーターのスタイル
  // =====================
  static BoxDecoration getGrowthIndicator(bool isActive) {
    return BoxDecoration(
      color: isActive ? AppColors.primary : AppColors.divider,
      shape: BoxShape.circle,
    );
  }

  // =====================
  // 作業完了ボタンのスタイル
  // =====================
  static BoxDecoration get completedTaskDecoration {
    return BoxDecoration(
      color: AppColors.success.withOpacity(0.1),
      border: Border.all(color: AppColors.success),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // =====================
  // 緊急通知のスタイル
  // =====================
  static BoxDecoration get urgentNotificationDecoration {
    return BoxDecoration(
      color: AppColors.urgent.withOpacity(0.1),
      border: Border.all(color: AppColors.urgent, width: 2),
      borderRadius: BorderRadius.circular(12),
    );
  }
}

/// アニメーション設定
class AppAnimations {
  AppAnimations._();

  // =====================
  // 標準アニメーション時間
  // =====================
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // =====================
  // 標準アニメーションカーブ
  // =====================
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;

  // =====================
  // ページトランジション
  // =====================
  static Route<T> createRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

/// レスポンシブ対応用のブレークポイント
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}

/// 定数値
class AppConstants {
  AppConstants._();

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

  // =====================
  // エレベーション
  // =====================
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
}