# やさいせんせい デザインシステム

## 🎨 デザインコンセプト

**「親しみやすい野菜の先生」**
- 初心者でも安心して使える温かみのあるデザイン
- 自然・成長・学びを表現するビジュアル
- ユーザーに考えさせない直感的なUI

## 🌈 カラーパレット

### プライマリカラー
```
緑系（自然・野菜・成長を表現）
- Primary 500: #4CAF50
- Primary 300: #81C784
- Primary 700: #388E3C
```

### セカンダリカラー
```
オレンジ系（太陽・元気・収穫を表現）
- Secondary 500: #FF9800
- Secondary 300: #FFB74D
- Secondary 700: #F57C00
```

### アクセントカラー
```
黄色系（明るさ・注意喚起）
- Accent: #FFC107
- Warning: #FF5722
- Success: #4CAF50
- Info: #2196F3
```

### ニュートラルカラー
```
- Background: #FAFAFA
- Surface: #FFFFFF
- OnSurface: #333333
- OnBackground: #424242
- Disabled: #9E9E9E
- Divider: #E0E0E0
```

## ✍️ タイポグラフィ

### フォントファミリー
- **プライマリ**: Noto Sans JP
- **セカンダリ**: Roboto（英数字）

### フォントスケール
```
- Headline1: 32sp, Bold
- Headline2: 24sp, Bold
- Headline3: 20sp, Medium
- Subtitle1: 18sp, Medium
- Body1: 16sp, Regular
- Body2: 14sp, Regular
- Button: 16sp, Medium
- Caption: 12sp, Regular
```

### 読みやすさ配慮
- 最小フォントサイズ：14sp
- 行間：1.4〜1.6倍
- コントラスト比：4.5:1以上

## 🧩 コンポーネント設計

### ボタン
**プライマリボタン**
```
- 背景色: Primary 500 (#4CAF50)
- テキスト色: White
- 高さ: 48dp
- 角丸: 8dp
- エレベーション: 2dp
```

**セカンダリボタン**
```
- 背景色: Transparent
- 枠線: 2dp Primary 500
- テキスト色: Primary 500
- 高さ: 48dp
- 角丸: 8dp
```

### カード
**野菜カード**
```
- 背景色: Surface White
- 角丸: 12dp
- エレベーション: 4dp
- パディング: 16dp
- アスペクト比: 1:1.2
```

**情報カード**
```
- 背景色: Surface White
- 角丸: 8dp
- エレベーション: 2dp
- パディング: 16dp
```

### 入力フィールド
```
- 枠線: 1dp OnSurface (20% opacity)
- フォーカス時: 2dp Primary 500
- 高さ: 56dp
- 角丸: 8dp
- パディング: 16dp horizontal
```

## 🖼️ アイコン・イラスト仕様

### アイコンスタイル
- **スタイル**: Material Design Icons + カスタム野菜アイコン
- **サイズ**: 24dp, 32dp, 48dp
- **色**: OnSurface (#333333), Primary (#4CAF50)

### 野菜アイコン（12種類）
```
1. トマト: 🍅 - 赤色ベース
2. きゅうり: 🥒 - 緑色ベース
3. ナス: 🍆 - 紫色ベース
4. オクラ: - 緑色ベース
5. バジル: 🌿 - 緑色ベース
6. サニーレタス: 🥬 - 緑色ベース
7. 二十日大根: - 白・ピンクベース
8. ほうれん草: - 濃緑色ベース
9. 小カブ: - 白・緑ベース
10. ピーマン: 🫑 - 緑色ベース
11. しそ: - 緑色ベース
12. モロヘイヤ: - 緑色ベース
```

### 状態アイコン
```
- 成長段階: 🌱→🌿→🌾→🍅
- 作業タイプ: 💧（水やり）, ✂️（間引き）, 🥕（収穫）
- AI相談: 🤖, 💬
- 通知: 🔔, ⏰
```

## 📱 画面レイアウト原則

### 共通レイアウト
```
- 画面マージン: 16dp
- 要素間スペース: 8dp, 16dp, 24dp
- セーフエリア対応必須
- タップエリア最小サイズ: 44dp
```

### ナビゲーション
**ボトムナビゲーション**
```
- 高さ: 56dp
- アイコンサイズ: 24dp
- ラベル: Body2 (14sp)
- 背景色: Surface White
```

**トップバー**
```
- 高さ: 56dp
- タイトル: Headline3 (20sp)
- アイコン: 24dp
- 背景色: Primary 500
```

## 🎯 画面別デザイン詳細

### 1. 野菜一覧画面
**レイアウト**
- グリッド: 2列
- カード間スペース: 8dp
- ヘッダー: 「栽培中の野菜」+ 追加ボタン

**カード内容**
- 野菜アイコン（48dp）
- 野菜名（Subtitle1）
- 植えた日からの経過日数
- 次の作業（バッジ表示）
- 成長段階インジケーター

### 2. 野菜詳細画面
**セクション構成**
- ヘッダー: 野菜名 + アイコン
- 次の作業予定（強調表示）
- 作業履歴（タイムライン形式）
- AI相談ボタン（目立つ配置）

### 3. AI相談画面
**チャットUI**
- ユーザーメッセージ: 右寄せ、Primary色
- AI返答: 左寄せ、Surface色
- アバター: 「せんせい」キャラクター
- 入力欄: 下部固定

### 4. 通知・フィードバック画面
**通知表示**
- 大きなアイコン（64dp）
- 通知内容（Headline2）
- 説明文（Body1）

**フィードバック選択**
- 大きなボタン（最小56dp高）
- 分かりやすいアイコン付き
- タップ後の完了アニメーション

### 5. 設定画面
**リスト形式**
- 設定項目ごとにカード
- 右矢印 or スイッチ
- 説明文付き

## 🎨 状態表現

### 成長段階の色分け
```
- 種まき/植え付け: #FFC107 (黄色)
- 成長期: #4CAF50 (緑色)
- 開花期: #FF9800 (オレンジ)
- 収穫期: #F44336 (赤色)
```

### 作業優先度
```
- 緊急: #FF5722 (赤)
- 重要: #FF9800 (オレンジ)
- 通常: #4CAF50 (緑)
- 完了: #9E9E9E (グレー)
```

## 🔄 アニメーション・フィードバック

### マイクロインタラクション
- ボタンタップ: 軽いスケール変化
- カード選択: エレベーション変化
- 完了時: チェックマークアニメーション
- 読み込み: シンプルなスピナー

### トランジション
- 画面遷移: 300ms ease-in-out
- 要素の表示/非表示: 150ms
- 色変化: 200ms

## 📐 レスポンシブ対応

### 画面サイズ対応
- 小画面（~360dp）: 1列レイアウト
- 中画面（361-600dp）: 2列レイアウト
- 大画面（601dp~）: 3列レイアウト

### 方向対応
- 縦向き: 標準レイアウト
- 横向き: より多くの情報を表示

## 🛠️ 実装考慮事項

### Flutter実装
- Material Design 3 準拠
- カスタムテーマクラス作成
- 色・フォントは constants で管理
- ダークモード対応（将来）

### アクセシビリティ
- セマンティクスラベル設定
- 十分なコントラスト比
- スクリーンリーダー対応
- タップエリア確保

### パフォーマンス
- 画像最適化
- アニメーション60fps維持
- メモリ効率的な実装

---

**最終更新**: 2025年7月  
**作成者**: atsushi  
**バージョン**: 1.0