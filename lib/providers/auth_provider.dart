import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';

/// 認証状態管理プロバイダー
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  StreamSubscription<AuthState>? _authSubscription;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _init();
  }

  void _init() {
    // 現在のユーザー状態を取得
    _currentUser = SupabaseService.currentUser;
    
    // 認証状態の変更を監視（StreamSubscriptionを保存）
    _authSubscription = SupabaseService.authStateChanges.listen((AuthState data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  /// メール・パスワードでサインアップ
  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      print('🚀 Starting signup for: $email');
      print('🔗 Starting Supabase signup...');

      final AuthResponse response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      print('📥 Signup response: ${response.user?.id}');
      print('📧 User email: ${response.user?.email}');
      print('✅ User confirmed: ${response.user?.emailConfirmedAt}');
      print('🔐 Session: ${response.session?.accessToken != null ? 'EXISTS' : 'NULL'}');

      if (response.user != null) {
        _currentUser = response.user;
        print('✅ Signup successful for user: ${response.user!.id}');
        return true;
      } else {
        print('❌ Signup failed: No user returned');
        _setError('アカウント作成に失敗しました');
        return false;
      }
    } on AuthException catch (e) {
      print('🚨 AuthException: ${e.message}');
      print('🚨 AuthException statusCode: ${e.statusCode}');
      _setError(_getJapaneseErrorMessage(e.message));
      return false;
    } catch (e) {
      print('💥 Unexpected error: $e');
      print('💥 Error type: ${e.runtimeType}');
      _setError('予期しないエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// メール・パスワードでサインイン
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      final AuthResponse response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        return true;
      } else {
        _setError('ログインに失敗しました');
        return false;
      }
    } on AuthException catch (e) {
      _setError(_getJapaneseErrorMessage(e.message));
      return false;
    } catch (e) {
      _setError('予期しないエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// パスワードリセット
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      clearError();

      await SupabaseService.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.atsudev.vegetable-teacher://reset-password',
      );

      return true;
    } on AuthException catch (e) {
      _setError(_getJapaneseErrorMessage(e.message));
      return false;
    } catch (e) {
      _setError('予期しないエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await SupabaseService.client.auth.signOut();
      _currentUser = null;
    } catch (e) {
      _setError('ログアウトに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// セッション更新
  Future<void> refreshSession() async {
    try {
      await SupabaseService.client.auth.refreshSession();
      _currentUser = SupabaseService.currentUser;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(_getJapaneseErrorMessage(e.message));
    } catch (e) {
      _setError('セッション更新に失敗しました: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Supabaseエラーメッセージを日本語に変換
  String _getJapaneseErrorMessage(String message) {
    switch (message.toLowerCase()) {
      case 'invalid login credentials':
        return 'メールアドレスまたはパスワードが正しくありません';
      case 'user not found':
        return 'ユーザーが見つかりません';
      case 'email already registered':
        return 'このメールアドレスは既に登録されています';
      case 'password should be at least 6 characters':
        return 'パスワードは6文字以上で入力してください';
      case 'invalid email':
        return '有効なメールアドレスを入力してください';
      case 'signup disabled':
        return '現在新規登録は無効になっています';
      case 'too many requests':
        return 'リクエストが多すぎます。しばらく待ってからお試しください';
      default:
        return message;
    }
  }

  @override
  void dispose() {
    // StreamSubscriptionをキャンセルしてメモリリークを防止
    _authSubscription?.cancel();
    super.dispose();
  }
}