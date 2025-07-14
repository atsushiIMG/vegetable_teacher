// やさいせんせい テキストスタイル定義
// Material Design 3準拠

import 'package:flutter/material.dart';
import 'colors.dart';

/// アプリ全体で使用するテキストスタイル
class AppTextStyles {
  AppTextStyles._();

  // =====================
  // フォントファミリー
  // =====================
  static const String primaryFontFamily = 'Noto Sans JP';
  static const String secondaryFontFamily = 'Roboto'; // 英数字用

  // =====================
  // ヘッドライン（見出し）
  // =====================
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.4,
  );

  // =====================
  // サブタイトル
  // =====================
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.4,
  );

  // =====================
  // ボディテキスト
  // =====================
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.5,
  );

  // =====================
  // ボタンテキスト
  // =====================
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    height: 1.2,
  );

  // =====================
  // キャプション・その他
  // =====================
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.disabled,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    color: AppColors.disabled,
    height: 1.4,
    letterSpacing: 1.5,
  );

  // =====================
  // 特殊用途スタイル
  // =====================

  /// エラーメッセージ用
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.error,
    height: 1.4,
  );

  /// 成功メッセージ用
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.success,
    height: 1.4,
  );

  /// 警告メッセージ用
  static const TextStyle warning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.warning,
    height: 1.4,
  );

  /// 野菜名表示用（強調）
  static const TextStyle vegetableName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: primaryFontFamily,
    color: AppColors.primary,
    height: 1.3,
  );

  /// AI相談のユーザーメッセージ用
  static const TextStyle chatUser = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: Colors.white,
    height: 1.4,
  );

  /// AI相談のAI返答用
  static const TextStyle chatAI = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.4,
  );

  /// 通知テキスト用（大きめ）
  static const TextStyle notification = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    color: AppColors.onSurface,
    height: 1.3,
  );

  /// バッジテキスト用（小さめ）
  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    fontFamily: primaryFontFamily,
    color: Colors.white,
    height: 1.2,
  );

  /// 数値表示用（モノスペース風）
  static const TextStyle number = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: secondaryFontFamily, // 英数字はRoboto
    color: AppColors.onSurface,
    height: 1.2,
  );

  /// 日付表示用
  static const TextStyle date = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: primaryFontFamily,
    color: AppColors.disabled,
    height: 1.3,
  );

  // =====================
  // レスポンシブ対応メソッド
  // =====================

  /// 画面サイズに応じたテキストスタイルを取得
  static TextStyle getResponsiveHeadline1(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return headline1.copyWith(fontSize: 28); // 小画面では少し小さく
    }
    return headline1;
  }

  static TextStyle getResponsiveHeadline2(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return headline2.copyWith(fontSize: 22);
    }
    return headline2;
  }

  static TextStyle getResponsiveBody1(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return body1.copyWith(fontSize: 14); // 小画面では最小14sp確保
    }
    return body1;
  }

  // =====================
  // テーマ用テキストスタイル
  // =====================

  /// Material Design 3用のTextTheme
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: headline1,
      displayMedium: headline2,
      displaySmall: headline3,
      headlineLarge: headline1,
      headlineMedium: headline2,
      headlineSmall: headline3,
      titleLarge: subtitle1,
      titleMedium: subtitle2,
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: primaryFontFamily,
        height: 1.4,
      ),
      bodyLarge: body1,
      bodyMedium: body2,
      bodySmall: caption,
      labelLarge: button,
      labelMedium: buttonSmall,
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: primaryFontFamily,
        height: 1.2,
      ),
    );
  }

  // =====================
  // アクセシビリティ対応
  // =====================

  /// 高コントラストモード用のテキストスタイル
  static TextStyle getHighContrastStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  /// 大きなフォント用のテキストスタイル
  static TextStyle getLargeTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * 1.3,
    );
  }
}

/// テキストスタイルの拡張メソッド
extension TextStyleExtensions on TextStyle {
  /// 色を変更
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }

  /// フォントサイズを変更
  TextStyle withSize(double size) {
    return copyWith(fontSize: size);
  }

  /// フォントウェイトを変更
  TextStyle withWeight(FontWeight weight) {
    return copyWith(fontWeight: weight);
  }

  /// 透明度を適用
  TextStyle withOpacity(double opacity) {
    return copyWith(color: color?.withOpacity(opacity));
  }
}