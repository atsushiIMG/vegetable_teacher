# やさいせんせい 🌱

家庭菜園初心者向けの栽培管理アプリ。植え方から収穫まで、適切なタイミングで通知し、AIに相談もできる。

## 🚀 セットアップ

### 前提条件
- Flutter SDK (3.7.2以上)
- Android Studio / VS Code
- Supabaseアカウント

### 環境変数の設定

1. `.env.example` をコピーして `.env` を作成
```bash
cp .env.example .env
```

2. `.env` ファイルに実際の値を設定
```bash
# 必須設定
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

3. Supabaseの設定
   - [Supabase](https://supabase.com)でプロジェクトを作成
   - Settings → API からURL・キーを取得
   - **⚠️ 重要**: APIキーは絶対にGitにコミットしないでください

### ビルド・実行

#### 開発環境での実行
```bash
# 依存関係のインストール
flutter pub get

# 環境変数を指定してデバッグ実行
flutter run --dart-define=SUPABASE_ANON_KEY=your-key-here
```

#### 本番ビルド
```bash
# APKビルド
flutter build apk --dart-define=SUPABASE_ANON_KEY=your-key-here

# AABビルド（Google Play用）
flutter build appbundle --dart-define=SUPABASE_ANON_KEY=your-key-here
```

## 🏗️ 技術スタック

- **フロントエンド**: Flutter
- **バックエンド**: Supabase (PostgreSQL)
- **認証**: Supabase Auth
- **ストレージ**: Supabase Storage
- **AI機能**: OpenAI API (予定)
- **通知**: Supabase Realtime + Local Notifications

## 📱 主要機能

### 実装済み
- ✅ 認証機能（サインアップ・ログイン）
- ✅ 認証状態管理
- ✅ 基本的なUI・テーマ

### 開発予定
- 🔄 野菜管理機能
- 🔄 栽培スケジュール・通知
- 🔄 AI相談機能
- 🔄 成長記録・写真管理

## 🔐 セキュリティ

- API キーは環境変数で管理
- 機密情報は `.gitignore` で除外
- カスタムURIスキームで認証フロー保護

## 📖 開発ドキュメント

詳細な仕様は `docs/` フォルダを参照：
- [設計書](docs/design.md)
- [開発ロードマップ](docs/roadmap.md)
- [プロジェクト仕様](CLAUDE.md)

## 🤝 コントリビューション

1. このリポジトリをfork
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにpush (`git push origin feature/amazing-feature`)
5. Pull Requestを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
