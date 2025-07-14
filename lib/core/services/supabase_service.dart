import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabaseクライアントへのアクセス用サービス
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  /// 現在のユーザー
  static User? get currentUser => client.auth.currentUser;
  
  /// 認証状態
  static bool get isAuthenticated => currentUser != null;
  
  /// 認証状態の変更ストリーム
  static Stream<AuthState> get authStateChanges => 
    client.auth.onAuthStateChange;
}

/// データベーステーブル名定数
class TableNames {
  static const String vegetables = 'vegetables';
  static const String userVegetables = 'user_vegetables';
  static const String notifications = 'notifications';
  static const String consultations = 'consultations';
  static const String photos = 'photos';
  static const String userLearningProfiles = 'user_learning_profiles';
}

/// ストレージバケット名定数
class BucketNames {
  static const String photos = 'photos';
  static const String icons = 'icons';
}