# Flutterプロジェクト構造（Screen First）

## 📁 ディレクトリ構成

```
lib/
├── main.dart               # エントリーポイント
│
├── core/                   # アプリ全体で使用する共通機能
│   ├── constants/         # 定数定義
│   │   └── app_constants.dart
│   ├── themes/            # テーマ・デザインシステム
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── utils/             # ユーティリティ関数
│   └── services/          # 共通サービス
│       └── supabase_service.dart
│
├── screens/               # 画面別ディレクトリ
│   ├── auth/             # 認証画面
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── password_reset_screen.dart
│   │
│   ├── vegetables/       # 野菜関連画面
│   │   ├── vegetable_list_screen.dart
│   │   ├── vegetable_detail_screen.dart
│   │   ├── add_vegetable_screen.dart
│   │   └── vegetable_calendar_screen.dart
│   │
│   ├── ai_chat/         # AI相談画面
│   │   ├── ai_chat_screen.dart
│   │   └── chat_history_screen.dart
│   │
│   └── settings/        # 設定画面
│       ├── settings_screen.dart
│       ├── notification_settings_screen.dart
│       └── profile_screen.dart
│
├── models/              # データモデル
│   ├── user.dart
│   ├── vegetable.dart
│   ├── user_vegetable.dart
│   ├── notification.dart
│   └── chat_message.dart
│
├── providers/           # 状態管理プロバイダー
│   ├── auth_provider.dart
│   ├── vegetable_provider.dart
│   ├── notification_provider.dart
│   └── ai_chat_provider.dart
│
├── services/            # 外部API・データアクセス
│   ├── auth_service.dart
│   ├── vegetable_service.dart
│   ├── notification_service.dart
│   └── ai_service.dart
│
└── widgets/             # 再利用可能ウィジェット
    ├── common/          # 汎用コンポーネント
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   └── loading_indicator.dart
    │
    ├── vegetable/       # 野菜関連ウィジェット
    │   ├── vegetable_card.dart
    │   ├── growth_indicator.dart
    │   └── task_badge.dart
    │
    └── chat/           # チャット関連ウィジェット
        ├── chat_bubble.dart
        ├── ai_avatar.dart
        └── quick_reply_buttons.dart
```

## 🏗️ Screen First アーキテクチャの特徴

### 画面中心の設計
- **screens/**: 各画面が独立したディレクトリに配置
- **明確な分離**: 画面ごとに関連ファイルをグループ化
- **直感的**: ファイル構造が画面構成と一致

### 共有コンポーネント
- **models/**: 全体で共有されるデータ構造
- **providers/**: 状態管理（画面をまたぐ状態）
- **services/**: 外部API・データアクセス層
- **widgets/**: 再利用可能なUIコンポーネント

### 依存関係の方向
```
screens/ → providers/ → services/
    ↓         ↓          ↓
  widgets/ → models/ → core/
```

## 📋 命名規則

### ファイル命名
- **画面**: `*_screen.dart` (例: `login_screen.dart`)
- **ウィジェット**: `*_widget.dart` または機能名 (例: `vegetable_card.dart`)
- **モデル**: 単数形 (例: `vegetable.dart`)
- **プロバイダー**: `*_provider.dart`
- **サービス**: `*_service.dart`

### クラス命名
- **画面**: `*Screen` (例: `LoginScreen`)
- **ウィジェット**: 機能を表す名前 (例: `VegetableCard`)
- **モデル**: 単数形 (例: `Vegetable`)

## 🎯 現在の実装状況

### ✅ 完了
- ✅ プロジェクト構造をscreen firstに変更
- ✅ core/ (テーマ、定数、サービス)
- ✅ providers/ (基本プロバイダー3つ)
- ✅ main.dart のimportパス修正

### 🚧 次の実装予定
1. **screens/auth/** - 認証画面
2. **screens/vegetables/** - 野菜管理画面
3. **models/** - データモデル定義
4. **services/** - API呼び出し
5. **widgets/** - 再利用可能コンポーネント

## 🛠️ 開発ガイドライン

### 新しい画面追加時
1. `screens/カテゴリ名/` ディレクトリに画面ファイルを作成
2. 必要に応じて専用ウィジェットを `widgets/` に作成
3. 状態管理が必要な場合は `providers/` にプロバイダー作成

### ファイル作成時
- 画面は`screens/`以下の適切なカテゴリに配置
- 複数画面で使用するウィジェットは`widgets/`に配置
- データアクセスは`services/`に集約

### import順序
1. Flutter framework
2. サードパーティパッケージ
3. 自分のプロジェクトのファイル（相対パス）

## 🚀 Screen Firstの利点

1. **直感的な構造**: 画面とディレクトリが対応
2. **開発効率**: 新しい画面を追加しやすい
3. **チーム開発**: 画面ごとに作業分担しやすい
4. **メンテナンス**: 特定の画面の修正箇所が見つけやすい
5. **スケーラビリティ**: 画面数が増えても構造が破綻しない