# ストレージ使用ガイド

## 概要
やさいせんせいの写真管理機能の使用方法とFlutterアプリでの実装例

## バケット構成
- **バケット名**: `vegetable-photos`
- **公開設定**: 公開（読み取り）
- **ファイルサイズ制限**: 50MB
- **対応形式**: JPEG, PNG, WebP, GIF

## フォルダ構造
```
vegetable-photos/
├── {user_id}/
│   ├── {user_vegetable_id}/
│   │   ├── {timestamp}.jpg
│   │   ├── {timestamp}.png
│   │   └── ...
│   └── ...
└── ...
```

## Flutter実装例

### 1. 写真アップロード
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> uploadPhoto({
  required File imageFile,
  required String userVegetableId,
}) async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('ユーザーが認証されていません');

    // ファイル拡張子を取得
    final extension = imageFile.path.split('.').last;
    
    // ファイルパスを生成
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filePath = '$userId/$userVegetableId/$fileName';

    // Supabase Storageにアップロード
    final response = await Supabase.instance.client.storage
        .from('vegetable-photos')
        .upload(filePath, imageFile);

    // URLを取得
    final photoUrl = Supabase.instance.client.storage
        .from('vegetable-photos')
        .getPublicUrl(filePath);

    // データベースに記録
    await Supabase.instance.client
        .from('photos')
        .insert({
          'user_vegetable_id': userVegetableId,
          'photo_url': photoUrl,
        });

    return photoUrl;
  } catch (e) {
    print('写真アップロードエラー: $e');
    return null;
  }
}
```

### 2. パラパラ漫画用写真取得
```dart
Future<List<Map<String, dynamic>>> getTimelapsePhotos(
  String userVegetableId,
) async {
  try {
    final response = await Supabase.instance.client
        .rpc('get_timelapse_photos', params: {
          'p_user_vegetable_id': userVegetableId,
        });

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('パラパラ漫画写真取得エラー: $e');
    return [];
  }
}
```

### 3. サムネイル表示
```dart
Widget buildPhotoThumbnail(String photoUrl) {
  // サムネイルURLを生成
  final thumbnailUrl = '$photoUrl?width=300&height=300&resize=cover';
  
  return Image.network(
    thumbnailUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Center(child: CircularProgressIndicator());
    },
    errorBuilder: (context, error, stackTrace) {
      return Icon(Icons.error);
    },
  );
}
```

### 4. 写真削除
```dart
Future<bool> deletePhoto(String photoUrl, String photoId) async {
  try {
    // URLからファイルパスを抽出
    final uri = Uri.parse(photoUrl);
    final filePath = uri.pathSegments.last;

    // Storageから削除
    await Supabase.instance.client.storage
        .from('vegetable-photos')
        .remove([filePath]);

    // データベースから削除
    await Supabase.instance.client
        .from('photos')
        .delete()
        .eq('id', photoId);

    return true;
  } catch (e) {
    print('写真削除エラー: $e');
    return false;
  }
}
```

## セキュリティ

### RLSポリシー
- **読み取り**: 全ユーザーが可能
- **書き込み**: 認証済みユーザーが自分のフォルダにのみ可能
- **更新・削除**: 自分の写真のみ可能

### ファイル制限
- **サイズ**: 最大50MB
- **形式**: JPEG, PNG, WebP, GIF
- **命名**: タイムスタンプベース

## 自動クリーンアップ
- アーカイブされた野菜の写真は90日後に自動削除
- 定期的なクリーンアップ処理が実行される

## 使用上の注意
1. ファイルサイズは50MB以内に制限
2. 対応形式以外はアップロード不可
3. 削除した写真は復元不可
4. パラパラ漫画は撮影順序で表示