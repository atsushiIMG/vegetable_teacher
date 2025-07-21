import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/services/supabase_service.dart';

/// 認証状態管理プロバイダー
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  StreamSubscription<AuthState>? _authSubscription;
  late GoogleSignIn _googleSignIn;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Google Sign-In の初期化（v6.x仕様）
    final googleClientId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (googleClientId == null || googleClientId.isEmpty) {
      throw Exception('GOOGLE_CLIENT_IDが環境変数に設定されていません');
    }
    
    _googleSignIn = GoogleSignIn(
      scopes: ['email'], // emailスコープのみ（最小限のアクセス）
      serverClientId: googleClientId,
    );

    // 現在のユーザー状態を取得
    _currentUser = SupabaseService.currentUser;

    // 認証状態の変更を監視（StreamSubscriptionを保存）
    _authSubscription = SupabaseService.authStateChanges.listen((
      AuthState data,
    ) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  /// Googleアカウントでサインイン
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      clearError();


      // Google Sign-In を実行
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setError('Googleサインインがキャンセルされました');
        return false;
      }


      // Google認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        _setError('Google認証トークンの取得に失敗しました');
        return false;
      }


      // SupabaseでGoogle認証
      final AuthResponse response = await SupabaseService.client.auth
          .signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: googleAuth.idToken!,
            accessToken: googleAuth.accessToken,
          );

      if (response.user != null) {
        _currentUser = response.user;
        return true;
      } else {
        _setError('Google認証に失敗しました');
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

  /// サインアウト
  Future<void> signOut() async {
    try {
      _setLoading(true);

      // Supabaseからサインアウト
      await SupabaseService.client.auth.signOut();

      // Google Sign-Inからもサインアウト
      await _googleSignIn.signOut();

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
        return 'Google認証に失敗しました';
      case 'user not found':
        return 'ユーザーが見つかりません';
      case 'signup disabled':
        return '現在新規登録は無効になっています';
      case 'too many requests':
        return 'リクエストが多すぎます。しばらく待ってからお試しください';
      case 'invalid id token':
        return 'Google認証トークンが無効です';
      case 'provider not supported':
        return 'Google認証プロバイダーがサポートされていません';
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
