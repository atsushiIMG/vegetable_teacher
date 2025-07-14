# やさいせんせい Flutter テーマ設定

このディレクトリには、「やさいせんせい」アプリのFlutterテーマファイルが含まれています。

## 📁 ファイル構成

```
flutter_theme/
├── colors.dart          # カラーパレット定義
├── text_styles.dart     # テキストスタイル定義
├── app_theme.dart       # メインテーマ設定
└── README.md           # このファイル
```

## 🎨 使用方法

### 1. MaterialAppでテーマを設定

```dart
import 'package:flutter/material.dart';
import 'flutter_theme/app_theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'やさいせんせい',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, // 将来実装
      home: HomeScreen(),
    );
  }
}
```

### 2. カラーの使用

```dart
import 'flutter_theme/colors.dart';

// 基本カラー
Container(
  color: AppColors.primary,
  child: Text('Hello', style: TextStyle(color: AppColors.onSurface)),
)

// 野菜固有カラー
Container(
  color: AppColors.getVegetableColor('トマト'),
  child: Icon(Icons.local_florist),
)

// 成長段階カラー
Container(
  color: AppColors.getGrowthStageColor('成長期'),
  child: Text('成長中'),
)
```

### 3. テキストスタイルの使用

```dart
import 'flutter_theme/text_styles.dart';

Column(
  children: [
    Text('見出し', style: AppTextStyles.headline1),
    Text('サブタイトル', style: AppTextStyles.subtitle1),
    Text('本文', style: AppTextStyles.body1),
    Text('野菜名', style: AppTextStyles.vegetableName),
  ],
)

// レスポンシブ対応
Text(
  '見出し',
  style: AppTextStyles.getResponsiveHeadline1(context),
)
```

### 4. カスタムテーマの使用

```dart
import 'flutter_theme/app_theme.dart';

// 野菜カード
Container(
  decoration: CustomTheme.vegetableCardDecoration,
  child: VegetableCard(),
)

// チャットバブル
Container(
  decoration: CustomTheme.userChatBubble,
  child: Text('ユーザーメッセージ'),
)

Container(
  decoration: CustomTheme.aiChatBubble,
  child: Text('AI返答'),
)
```

### 5. アニメーションの使用

```dart
import 'flutter_theme/app_theme.dart';

// ページ遷移
Navigator.of(context).push(
  AppAnimations.createRoute(NextPage()),
);

// アニメーション時間
AnimatedContainer(
  duration: AppAnimations.normal,
  curve: AppAnimations.defaultCurve,
  // ...
)
```

### 6. レスポンシブ対応

```dart
import 'flutter_theme/app_theme.dart';

Widget build(BuildContext context) {
  if (AppBreakpoints.isMobile(context)) {
    return MobileLayout();
  } else if (AppBreakpoints.isTablet(context)) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

### 7. 定数値の使用

```dart
import 'flutter_theme/app_theme.dart';

Padding(
  padding: EdgeInsets.all(AppConstants.paddingM),
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
    ),
    elevation: AppConstants.elevationM,
    child: Icon(
      Icons.eco,
      size: AppConstants.iconL,
    ),
  ),
)
```

## 🛠️ カスタマイズ方法

### 新しいカラーを追加

```dart
// colors.dart に追加
class AppColors {
  // 既存のカラー...
  
  static const Color newColor = Color(0xFF123456);
}
```

### 新しいテキストスタイルを追加

```dart
// text_styles.dart に追加
class AppTextStyles {
  // 既存のスタイル...
  
  static const TextStyle newStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: primaryFontFamily,
    color: AppColors.newColor,
  );
}
```

### カスタムデコレーションを追加

```dart
// app_theme.dart の CustomTheme クラスに追加
class CustomTheme {
  // 既存のデコレーション...
  
  static BoxDecoration get newDecoration {
    return BoxDecoration(
      color: AppColors.newColor,
      borderRadius: BorderRadius.circular(8),
      // ...
    );
  }
}
```

## 📱 対応デバイス

- **モバイル**: < 600dp
- **タブレット**: 600dp - 900dp
- **デスクトップ**: > 900dp

## ♿ アクセシビリティ

- **コントラスト比**: WCAG AA準拠（4.5:1以上）
- **最小フォントサイズ**: 14sp
- **最小タップエリア**: 44dp
- **スクリーンリーダー対応**: セマンティクスラベル設定

## 🌙 ダークモード

現在はライトモードのみ実装済み。ダークモードは将来のバージョンで実装予定。

## 📦 依存関係

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Material Design 3対応のFlutter 3.7以上が必要
```

## 🔄 更新履歴

- **v1.0.0**: 初期リリース
  - ライトテーマの実装
  - 野菜固有カラーの追加
  - レスポンシブ対応
  - アクセシビリティ対応

---

**作成日**: 2025年7月  
**バージョン**: 1.0