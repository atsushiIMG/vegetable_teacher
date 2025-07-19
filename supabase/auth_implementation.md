# 認証機能実装ガイド

## 概要
やさいせんせいの認証機能の実装方法とFlutter Android向けの使用例

## 認証機能

### 1. 基本認証設定
- **メール認証**: 有効
- **パスワード要件**: 8文字以上、大文字小文字含む
- **セッション時間**: 1時間（自動更新）
- **アカウント確認**: 無効（開発時）

### 2. ユーザープロファイル
- **自動作成**: 新規登録時に自動作成
- **表示名**: メールアドレスから自動生成
- **経験レベル**: 初心者/中級者/上級者
- **通知設定**: カスタマイズ可能

## Flutter実装例

### 1. 初期設定

#### AndroidManifest.xml の設定
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    
    <!-- 通常の起動用 -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep Link用（認証コールバック） -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.atsudev.vegetable_teacher_app" />
    </intent-filter>
</activity>
```

#### Dart側の初期設定
```dart
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  
  runApp(MyApp());
}
```

### 2. 認証サービス
```dart
// auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 現在のユーザー取得
  User? get currentUser => _supabase.auth.currentUser;

  // ログイン状態の監視
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // メール・パスワードでサインアップ
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName ?? email.split('@')[0],
        },
      );
      return response;
    } catch (e) {
      throw Exception('サインアップエラー: $e');
    }
  }

  // メール・パスワードでログイン
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('ログインエラー: $e');
    }
  }

  // ログアウト
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('ログアウトエラー: $e');
    }
  }

  // パスワードリセット
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('パスワードリセットエラー: $e');
    }
  }
}
```

### 3. ユーザープロファイル管理
```dart
// user_profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // プロファイル取得
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print('プロファイル取得エラー: $e');
      return null;
    }
  }

  // プロファイル更新
  Future<bool> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? location,
    String? experienceLevel,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('user_profiles').update({
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (location != null) 'location': location,
        if (experienceLevel != null) 'experience_level': experienceLevel,
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('プロファイル更新エラー: $e');
      return false;
    }
  }

  // 通知設定更新
  Future<bool> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('user_profiles').update({
        'notification_settings': settings,
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('通知設定更新エラー: $e');
      return false;
    }
  }

  // ユーザー統計取得
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print('統計取得エラー: $e');
      return null;
    }
  }
}
```

### 4. 認証画面例
```dart
// login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('ログイン'),
            ),
            TextButton(
              onPressed: () {
                // サインアップ画面に遷移
              },
              child: Text('新規アカウント作成'),
            ),
            TextButton(
              onPressed: _handleForgotPassword,
              child: Text('パスワードを忘れた場合'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ログイン成功時の処理
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインに失敗しました: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メールアドレスを入力してください')),
      );
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('パスワードリセットメールを送信しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }
}
```

### 5. 認証状態管理
```dart
// auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedWidget;
  final Widget unauthenticatedWidget;

  const AuthWrapper({
    Key? key,
    required this.authenticatedWidget,
    required this.unauthenticatedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            return authenticatedWidget;
          }
        }
        return unauthenticatedWidget;
      },
    );
  }
}
```

## セキュリティ設定

### 1. パスワードポリシー
- 最小8文字
- 大文字・小文字を含む
- 数字を含む
- 特殊文字は任意

### 2. セッション管理
- JWT有効期限: 1時間
- 自動リフレッシュ: 有効
- セッション回転: 有効

### 3. レート制限
- 最大試行回数: 5回
- 制限時間: 15分

## 通知設定

### デフォルト設定
```json
{
  "watering_reminders": true,
  "task_reminders": true,
  "harvest_reminders": true,
  "general_tips": true,
  "quiet_hours": {
    "enabled": false,
    "start": "22:00",
    "end": "08:00"
  }
}
```

## 使用上の注意

1. **プロダクション環境では**メール認証を有効化
2. **RLS（Row Level Security）**が全テーブルで有効
3. **プロファイル情報**は自動作成される
4. **セッション管理**は自動化されている
5. **エラーハンドリング**を適切に実装する