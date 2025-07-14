import 'package:flutter/foundation.dart';

/// 認証状態管理プロバイダー（基本実装）
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    // 初期化処理（後でSupabase実装時に追加）
  }

  /// サインイン（ダミー実装）
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    // ダミー処理
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _setLoading(false);
  }

  /// サインアウト（ダミー実装）
  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
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
}