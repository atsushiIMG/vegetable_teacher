import 'package:flutter/foundation.dart';

/// 通知管理プロバイダー（基本実装）
class NotificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationProvider() {
    _init();
  }

  void _init() {
    // 初期化処理（後で実装）
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