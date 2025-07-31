# やさいせんせい 開発メモ

## 🎯 開発開始時の重要な気づき

### 2025年7月 - バックエンド構築フェーズ

#### ✅ 成功したこと
- **クラウド開発の選択**: ローカル開発ではなくSupabaseクラウドでの開発が正解だった
- **段階的な設定修正**: config.toml、auth.config問題を順次解決
- **シードデータの手動投入**: SQL Editorでの直接実行が最も確実
- **RLS設定**: セキュリティファーストでの設計

#### ⚠️ 遭遇した問題と解決策

**1. Supabase CLI v2.30.4 設定互換性問題**
```
問題: config.tomlの古い設定形式でエラー
解決: storage.port、auth.port、functions セクションを削除
学び: CLI バージョンアップ時は設定形式の変更に注意
```

**2. auth.config テーブルアクセス問題**
```
問題: クラウド版では auth.config テーブルが存在しない
解決: 認証設定はWeb UIから手動で行う
学び: ローカル開発とクラウド開発の制約の違いを理解
```

**3. シードデータ投入方法の迷走**
```
問題: supabase db reset (Docker必要) → supabase seed (存在しない)
解決: Supabase Studio SQL Editorで手動実行
学び: クラウド開発では Web UI が最も確実
```

#### 🔧 技術的メモ

**Supabaseプロジェクト情報**
- プロジェクト名: やさいせんせい-dev
- リージョン: Northeast Asia (Tokyo)
- Reference ID: ssrfnkanoegmflgcvkpv

**重要なコマンド**
```bash
# マイグレーション適用 (クラウド用)
supabase db push

# プロジェクト接続
supabase link --project-ref ssrfnkanoegmflgcvkpv

# 状態確認
supabase projects list
```

**データベース構造のポイント**
- vegetables テーブル: JSONB でスケジュール管理
- RLS 全テーブル適用でセキュリティ確保
- user_vegetables で個人の栽培記録管理

## 💡 設計上の重要な判断

### 野菜スケジュール設計
```json
{
  "tasks": [
    {"day": 0, "type": "種まき", "description": "..."},
    {"day": 14, "type": "間引き", "description": "..."}
  ],
  "watering_base_interval": 2,
  "fertilizer_interval": 30
}
```
**判断理由**: JSONBで柔軟性を確保、野菜ごとに異なるスケジュールに対応

### 認証方式
- Android専用でカスタムURIスキーム採用
- `com.atsudev.vegetable_teacher://auth/callback`
- **判断理由**: モバイルアプリでの認証体験を最適化

## 🚨 今後注意すべき点

### 開発環境
- ローカル開発とクラウド開発のコマンドの違いに注意
- Docker 不要な構成で進める

### データ設計
- 通知タイミングの計算ロジックを明確化する必要
- フィードバックデータの活用方法を具体化

### API設計
- AI相談の責任範囲を明確にする
- エラーハンドリングを充実させる

## 📝 次フェーズへの引き継ぎ事項

### Flutter開発開始前の準備
- [ ] Flutter開発環境セットアップ
- [ ] Supabase Flutter SDKの調査
- [ ] UI/UXモックアップの作成

### AI相談API開発の準備
- [ ] OpenAI API キーの取得
- [ ] プロンプトエンジニアリング戦略
- [ ] 野菜専門知識の整理

### 通知機能開発の準備
- [x] Supabase Realtime通知機能実装
- [x] Local Notifications設定完了
- [x] 通知タイミング計算ロジックの実装完了

## 🤔 開発中の疑問・検討事項

### 技術的疑問
- Flutter でのSupabase認証実装方法
- プッシュ通知の最適な頻度設定
- AI回答の品質担保方法

### 機能面の検討
- 水やり通知の季節係数の具体的数値
- フィードバック選択肢の最適化
- 通知時間帯の個別設定の必要性

### ビジネス面の検討
- 無料版の機能範囲
- AI相談の回数制限の必要性
- 将来の収益化戦略

## 📊 参考リンク・資料

### 技術資料
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
- [Supabase Realtime Documentation](https://supabase.com/docs/guides/realtime)
- [OpenAI API Documentation](https://platform.openai.com/docs)

### 農業関連資料
- 各野菜の栽培カレンダー（JA資料参考）
- 家庭菜園初心者向けQ&A集
- 病害虫対策の基本知識