# やさいせんせい ワイヤーフレーム

## 📱 画面一覧

1. [認証画面](#1-認証画面)
2. [野菜一覧画面](#2-野菜一覧画面)
3. [野菜詳細画面](#3-野菜詳細画面)
4. [AI相談画面](#4-ai相談画面)
5. [通知設定画面](#5-通知設定画面)

---

## 1. 認証画面

### ログイン画面
```
┌─────────────────────────────────────┐
│ [←]    やさいせんせい              │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│         🌱                          │ <- ロゴ・アイコン (64dp)
│    やさいせんせい                   │ <- アプリ名 (Headline1)
│                                     │
│  家庭菜園を始めよう！               │ <- サブタイトル (Body1)
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ メールアドレス                  │ │ <- メール入力フィールド
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ パスワード                      │ │ <- パスワード入力フィールド
│ └─────────────────────────────────┘ │
│                                     │
│ [     ログイン     ] <- Primary Button │
│                                     │
│ ────────── または ──────────        │
│                                     │
│ [   Googleでログイン   ] <- Secondary   │
│                                     │
│     アカウントをお持ちでない方？     │ <- Body2
│          [新規登録]                 │ <- Text Button
│                                     │
└─────────────────────────────────────┘
```

### 新規登録画面
```
┌─────────────────────────────────────┐
│ [←]    新規登録                     │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 名前                            │ │ <- 名前入力フィールド
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ メールアドレス                  │ │ <- メール入力フィールド
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ パスワード                      │ │ <- パスワード入力フィールド
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ パスワード（確認）              │ │ <- 確認用フィールド
│ └─────────────────────────────────┘ │
│                                     │
│ [     登録する     ] <- Primary Button │
│                                     │
│      すでにアカウントをお持ちの方   │ <- Body2
│          [ログイン]                 │ <- Text Button
│                                     │
└─────────────────────────────────────┘
```

---

## 2. 野菜一覧画面

```
┌─────────────────────────────────────┐
│     やさいせんせい           [+]    │ <- AppBar + FAB
├─────────────────────────────────────┤
│                                     │
│  栽培中の野菜 (3)                   │ <- セクションタイトル
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │     🍅      │ │     🥒      │     │ <- 野菜カード（2列グリッド）
│ │   トマト    │ │  きゅうり   │     │
│ │  植えて15日  │ │  植えて8日   │     │
│ │             │ │             │     │
│ │ [🔔間引き時期]│ │ [💧水やり]  │     │ <- 次の作業バッジ
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │     🍆      │ │             │     │
│ │    ナス     │ │   野菜を    │     │
│ │  植えて22日  │ │  追加する   │     │ <- 追加カード
│ │             │ │     [+]     │     │
│ │ [🥕収穫予定] │ │             │     │
│ └─────────────┘ └─────────────┘     │
│                                     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📊 今週の作業予定                │ │ <- 作業予定セクション
│ │                                 │ │
│ │ • 7/15 トマトの間引き           │ │
│ │ • 7/17 ナスの水やり             │ │
│ │ • 7/19 きゅうりの支柱立て       │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ [🏠] [📅] [🤖] [⚙️]               │ <- BottomNavigation
└─────────────────────────────────────┘
```

---

## 3. 野菜詳細画面

```
┌─────────────────────────────────────┐
│ [←] トマト                    [⋮]  │ <- AppBar + メニュー
├─────────────────────────────────────┤
│                                     │
│      🍅                             │ <- 野菜アイコン (64dp)
│     トマト                          │ <- 野菜名 (Headline2)
│   植えて15日目                      │ <- 経過日数
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔔 次の作業                     │ │ <- 次の作業カード
│ │                                 │ │
│ │  間引き作業                     │ │ <- 作業名 (Headline3)
│ │  予定日: 明日 (7/15)            │ │ <- 予定日
│ │                                 │ │
│ │  元気な苗を1本残して、他の苗を  │ │ <- 作業説明
│ │  間引きましょう。土が乾いてい   │ │
│ │  るときに行うと良いです。       │ │
│ │                                 │ │
│ │ [    作業完了    ]              │ │ <- 完了ボタン
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📈 成長ステータス               │ │ <- 成長ステータス
│ │                                 │ │
│ │ ●○○○ 発芽期                   │ │ <- 進捗インジケーター
│ │                                 │ │
│ │ 水やり頻度: 2日に1回             │ │ <- 設定情報
│ │ 栽培方法: 鉢植え                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📋 作業履歴                         │ <- セクションタイトル
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 7/12 ✅ 種まき                  │ │ <- 履歴アイテム
│ │      順調に発芽しました          │ │
│ │ ─────────────────────────────── │ │
│ │ 7/10 ✅ 水やり                  │ │
│ │      土が十分湿っていました      │ │
│ │ ─────────────────────────────── │ │
│ │ 7/8  ✅ 種まき                  │ │
│ │      初回の種まきを行いました    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [🤖 AIに相談する]                   │ <- AI相談ボタン
│                                     │
└─────────────────────────────────────┘
```

---

## 4. AI相談画面

```
┌─────────────────────────────────────┐
│ [←] トマトの相談                    │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│         🤖                          │ <- AIアバター
│     やさいせんせい                  │ <- AI名前
│   トマトのことなら何でも聞いて！    │ <- 挨拶メッセージ
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 💬 よくある質問                 │ │ <- 質問候補
│ │                                 │ │
│ │ • 葉っぱが黄色くなってきた       │ │ <- 候補ボタン
│ │ • 花が咲かない                  │ │
│ │ • 虫がついている                │ │
│ │ • 実がならない                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│                                     │ <- チャット履歴エリア
│ ┌─────────────────────────────────┐ │
│ │ 過去の相談履歴                  │ │ <- 履歴セクション
│ │                                 │ │
│ │ 📅 7/10                         │ │
│ │ Q: 水やりの頻度について         │ │
│ │ A: トマトは土が乾いたら...      │ │
│ │                                 │ │
│ │ 📅 7/8                          │ │
│ │ Q: 種まきの深さについて         │ │
│ │ A: 種の2-3倍の深さに...         │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ ┌─────────────────┐ [送信]         │ <- 入力エリア
│ │ 相談内容を入力...   │               │
│ └─────────────────┘               │
└─────────────────────────────────────┘
```

### AI相談中画面
```
┌─────────────────────────────────────┐
│ [←] トマトの相談                    │
├─────────────────────────────────────┤
│                                     │
│                          ┌─────────┐│ <- ユーザーメッセージ
│                          │葉っぱが  ││
│                          │黄色くな  ││ <- 右寄せ、Primary色
│                          │ってきま  ││
│                          │した      ││
│                          └─────────┘│
│                                     │
│ ┌─────────────────┐                 │ <- AIメッセージ
│ │🤖 葉っぱが黄色くなる │                 │
│ │ 原因はいくつか考えら │                 │ <- 左寄せ、Surface色
│ │ れます：            │                 │
│ │                    │                 │
│ │ 1. 水のやりすぎ     │                 │
│ │ 2. 栄養不足        │                 │
│ │ 3. 病気の可能性    │                 │
│ │                    │                 │
│ │ まず土の状態を確認  │                 │
│ │ してみましょう...   │                 │
│ └─────────────────┘                 │
│                                     │
│                          ┌─────────┐│
│                          │ありがと  ││
│                          │うござい  ││
│                          │ます！    ││
│                          └─────────┘│
│                                     │
├─────────────────────────────────────┤
│ ┌─────────────────┐ [送信]         │
│ │ 追加で質問...       │               │
│ └─────────────────┘               │
└─────────────────────────────────────┘
```

---

## 5. 通知設定画面

```
┌─────────────────────────────────────┐
│ [←] 通知設定                        │ <- AppBar
├─────────────────────────────────────┤
│                                     │
│ 🔔 通知設定                         │ <- セクションタイトル
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 通知を許可する          [●○]    │ │ <- メイン通知切り替え
│ └─────────────────────────────────┘ │
│                                     │
│ 📅 通知時間                         │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 作業通知時間                    │ │
│ │                                 │ │
│ │ 午前    [08:00] 〜 [10:00]     │ │ <- 時間範囲選択
│ │ 午後    [16:00] 〜 [18:00]     │ │
│ │                                 │ │
│ │ 静音時間: 21:00 〜 07:00        │ │ <- 静音時間
│ └─────────────────────────────────┘ │
│                                     │
│ 💧 水やり設定                       │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 基本頻度                        │ │
│ │                                 │ │
│ │ 毎日      [○]                  │ │ <- ラジオボタン選択
│ │ 2日に1回  [●]                  │ │
│ │ 3日に1回  [○]                  │ │
│ │ カスタム  [○]                  │ │
│ │                                 │ │
│ │ 季節調整を自動で行う    [●○]    │ │ <- 自動調整
│ └─────────────────────────────────┘ │
│                                     │
│ 🎯 フィードバック設定               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 作業後のフィードバック  [●○]    │ │ <- フィードバック収集
│ │                                 │ │
│ │ 学習機能を有効にする    [●○]    │ │ <- 学習機能
│ │                                 │ │
│ │ より個人的な通知タイミングに    │ │ <- 説明文
│ │ 調整されます                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [     設定を保存     ]              │ <- 保存ボタン
│                                     │
└─────────────────────────────────────┘
```

---

## 🔄 画面遷移フロー

```
[認証画面] 
    ↓ ログイン成功
[野菜一覧画面] ←→ [野菜詳細画面] ←→ [AI相談画面]
    ↓                    ↓
[通知設定画面]       [作業完了画面]
```

## 📐 レスポンシブ考慮

### 小画面（~360dp）
- カードを1列配置
- フォントサイズを最小14sp確保
- タップエリアを最小44dp確保

### 中画面（361-600dp）
- 標準の2列グリッド
- 推奨レイアウト

### 大画面（601dp~）
- 3列グリッドまたはサイドバー追加
- より多くの情報を同時表示

## 🎨 デザイン適用

各画面に以下のデザインシステムを適用：

- **カラー**: design.mdで定義したカラーパレット
- **フォント**: Noto Sans JP + サイズスケール
- **コンポーネント**: 統一されたボタン・カード・入力フィールド
- **アイコン**: Material Design + カスタム野菜アイコン
- **アニメーション**: 軽やかなマイクロインタラクション

---

**作成日**: 2025年7月  
**バージョン**: 1.0