日本でやりとりしよう！
# やさいせんせい仕様書

## 概要
家庭菜園初心者向けの栽培管理アプリ「やさいせんせい」。植え方から収穫まで、適切なタイミングで通知し、AIに相談もできる。

## コアバリュー
- 作業を忘れない（プッシュ通知）
- 分からないことをAIに相談できる
- 成長記録を楽しめる（パラパラ漫画機能）

## 技術スタック
- **フロントエンド**: Flutter (Android アプリ)
- **バックエンド**: Python (FastAPI) - AI相談機能のみ
- **データベース**: Supabase (PostgreSQL)
- **認証**: Supabase Auth（メール認証、カスタムURIスキーム）
- **ストレージ**: Supabase Storage
- **プッシュ通知**: Supabase Functions + FCM
- **AI**: OpenAI API (GPT-4o-mini)
- **パッケージ名**: com.atsudev.vegetable_teacher

## 主要機能

### フェーズ1（MVP）

#### 1. 野菜管理機能
- 野菜を選んで栽培開始
- 登録時の入力項目：
  - 野菜の種類（12種類から選択）
  - 植えた日
  - 種/苗の選択
  - 鉢/畑の選択

#### 2. 通知機能
- 作業タイミングでプッシュ通知
- 通知内容（中間レベル）：
  - 種まき/植え付け
  - 間引き
  - 支柱立て（必要な野菜のみ）
  - 追肥
  - 収穫
- 水やりは共通設定（野菜ごとの基本頻度×季節係数）
- 通知後にフィードバック収集（選択式）
  - 例：「土の状態：カラカラ/少し湿ってる/十分湿ってる」
  - フィードバックに基づいて次回通知を調整

#### 3. AI相談機能
- テキストベースの相談
- 野菜ごとに会話履歴を保持
- 症状や対処法についてアドバイス

### フェーズ2

#### 4. 撮影モード機能
- 通知設定とは別に「撮影モード」ON/OFF
- ONにすると個別ID付与（例：オクラ#1）
- 作業通知時に「ついでに撮影も」と促す

#### 5. パラパラ漫画機能
- 撮影した写真を0.5秒間隔で自動再生
- 成長過程を視覚的に楽しめる

#### 6. 収穫記録機能
- 収穫時に継続/終了を選択
- 終了した記録はアーカイブへ
- パラパラ漫画は保存される

## 画面構成

### 必須画面
1. **野菜一覧/追加画面**
   - 栽培中の野菜リスト
   - 新規追加ボタン

2. **野菜詳細画面**
   - 次の作業予定
   - 作業履歴
   - AI相談ボタン
   - （フェーズ2）撮影モード切り替え

3. **AI相談画面**
   - チャット形式
   - 野菜ごとの相談履歴表示

4. **通知設定画面**
   - 通知時間帯
   - 水やり頻度調整

### フェーズ2追加画面
5. **カレンダー画面**
   - 作業予定一覧

6. **収穫記録画面**
   - パラパラ漫画表示
   - アーカイブ一覧

## データ設計

### Supabaseテーブル構造

#### vegetables（野菜マスタ）
```json
{
  "id": "uuid",
  "name": "トマト",
  "schedule": {
    "tasks": [
      {"day": 0, "type": "種まき", "description": "..."},
      {"day": 14, "type": "間引き", "description": "..."},
      {"day": 30, "type": "支柱立て", "description": "..."}
    ],
    "watering_base_interval": 3,
    "fertilizer_interval": 30
  },
  "growing_tips": "...",
  "common_problems": "..."
}
```

#### user_vegetables（ユーザーの栽培記録）
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "vegetable_id": "uuid",
  "planted_date": "2024-04-01",
  "plant_type": "種/苗",
  "location": "鉢/畑",
  "is_photo_mode": false,
  "photo_id": "オクラ#1",
  "status": "growing/harvested/archived",
  "schedule_adjustments": {},
  "created_at": "timestamp"
}
```

#### notifications（通知履歴）
```json
{
  "id": "uuid",
  "user_vegetable_id": "uuid",
  "task_type": "水やり",
  "scheduled_date": "2024-04-15",
  "sent_at": "timestamp",
  "feedback": {
    "soil_condition": "少し湿ってる",
    "completed": true
  }
}
```

#### consultations（AI相談履歴）
```json
{
  "id": "uuid",
  "user_vegetable_id": "uuid",
  "messages": [
    {"role": "user", "content": "葉っぱが..."},
    {"role": "assistant", "content": "それは..."}
  ],
  "created_at": "timestamp"
}
```

#### photos（写真記録）※フェーズ2
```json
{
  "id": "uuid",
  "user_vegetable_id": "uuid",
  "photo_url": "supabase_storage_url",
  "taken_at": "timestamp"
}
```

## 初期データ（9種類の野菜）
1. トマト
2. きゅうり
3. ナス
4. オクラ
5. バジル
6. サニーレタス
7. 二十日大根
8. ほうれん草
9. 小カブ
10. ピーマン
11. しそ
12. モロヘイヤ

## API設計（Python FastAPI）

### AI相談エンドポイントのみ
```python
POST /api/consultation
{
  "vegetable_type": "トマト",
  "message": "葉っぱが黄色くなってきました",
  "history": [...過去の会話履歴]
}
```

## 開発環境セットアップ

### 必要なツール
- **Supabase CLI**: npm install -g supabase
- **Flutter**: Android アプリ開発用
- **Python 3**: AI相談API開発用

### Supabaseクラウド開発環境
- **プロジェクト名**: やさいせんせい-dev
- **Reference ID**: ssrfnkanoegmflgcvkpv
- **リージョン**: Northeast Asia (Tokyo)

### 開発用コマンド
```bash
# プロジェクト接続
supabase link --project-ref ssrfnkanoegmflgcvkpv

# マイグレーション適用
supabase db push

# プロジェクト状態確認
supabase projects list
```

### アクセスURL（クラウド環境）
- **Supabase Studio**: https://supabase.com/dashboard/project/ssrfnkanoegmflgcvkpv
- **API URL**: https://ssrfnkanoegmflgcvkpv.supabase.co
- **Database**: クラウド PostgreSQL

## 開発順序
1. ✅ Supabaseセットアップ（認証、DB、Storage）
2. ✅ 野菜マスタデータ登録（12種類）
3. Flutter基本画面実装
4. 通知機能実装（Supabase Functions + FCM）
5. Python AI相談API実装
6. フィードバック機能追加
7. （フェーズ2）撮影モード実装
8. （フェーズ2）パラパラ漫画機能
9. （フェーズ2）収穫記録機能

## 今後の拡張可能性
- 野菜の種類追加
- 天気API連携（雨の日は水やり通知スキップ）
- コミュニティ機能（他のユーザーの栽培記録を見る）
- 画像診断機能（病害虫の判定）
