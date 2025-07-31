# Android認証設定ガイド

## 概要
やさいせんせいのAndroid向けSupabase認証設定の詳細ガイド

## 基本情報
- **パッケージ名**: `com.atsudev.vegetable_teacher`
- **カスタムURIスキーム**: `com.atsudev.vegetable_teacher://auth/callback`
- **認証フロー**: PKCE（Proof Key for Code Exchange）

## 1. Android設定

### pubspec.yaml
```yaml
name: vegetable_teacher
description: やさいせんせい

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  url_launcher: ^6.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### android/app/build.gradle
```gradle
android {
    namespace "com.atsudev.vegetable_teacher"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.atsudev.vegetable_teacher"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
```

### AndroidManifest.xml
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- インターネット権限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- 通知権限 -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application
        android:label="やさいせんせい"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
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
                <data android:scheme="com.atsudev.vegetable_teacher" />
            </intent-filter>
        </activity>
        
        <!-- Flutter の必要設定 -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
            
        <!-- Firebase Cloud Messaging -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

## 2. Supabase設定

### 環境変数設定
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // 開発環境用
  static const String devUrl = 'http://localhost:54321';
  static const String devAnonKey = 'YOUR_DEV_ANON_KEY';
  
  // 環境判定
  static bool get isDev => const bool.fromEnvironment('dart.vm.product') == false;
  
  static String get currentUrl => isDev ? devUrl : url;
  static String get currentAnonKey => isDev ? devAnonKey : anonKey;
}
```

### main.dart
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.currentUrl,
    anonKey: SupabaseConfig.currentAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  
  runApp(const VegetableTeacherApp());
}

class VegetableTeacherApp extends StatelessWidget {
  const VegetableTeacherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'やさいせんせい',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'NotoSansJP',
      ),
      home: const AuthWrapper(),
    );
  }
}
```

## 3. 認証実装

### AuthWrapper
```dart
// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _handleAuthState();
  }

  void _handleAuthState() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    return session != null 
        ? const HomeScreen() 
        : const LoginScreen();
  }
}
```

### AuthService
```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // サインアップ
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
      throw Exception('サインアップに失敗しました: $e');
    }
  }

  // サインイン
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
      throw Exception('ログインに失敗しました: $e');
    }
  }

  // サインアウト
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('ログアウトに失敗しました: $e');
    }
  }

  // パスワードリセット
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('パスワードリセットに失敗しました: $e');
    }
  }
}
```

## 4. Deep Link処理

### Deep Linkハンドラー
```dart
// lib/utils/deep_link_handler.dart
import 'package:flutter/services.dart';

class DeepLinkHandler {
  static const MethodChannel _channel = MethodChannel('deep_link_handler');

  // Deep Link URLを取得
  static Future<String?> getInitialLink() async {
    try {
      final String? link = await _channel.invokeMethod('getInitialLink');
      return link;
    } catch (e) {
      print('Deep Link取得エラー: $e');
      return null;
    }
  }

  // Deep Link URLを処理
  static void handleDeepLink(String url) {
    final uri = Uri.parse(url);
    
    // 認証コールバックの処理
    if (uri.scheme == 'com.atsudev.vegetable_teacher' && uri.host == 'auth') {
      // Supabaseが自動的に処理
      print('認証コールバックを受信: $url');
    }
  }
}
```

## 5. テスト設定

### テスト用の設定
```dart
// test/test_config.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void setupTestSupabase() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  });
}
```

## 6. デバッグ設定

### ログ設定
```dart
// lib/utils/logger.dart
import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kDebugMode) {
      print('[やさいせんせい] $message');
    }
  }
  
  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      print('[やさいせんせい ERROR] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }
}
```

## 7. 本番環境設定

### リリース設定
```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            // 署名設定
            signingConfig signingConfigs.release
            
            // 難読化設定
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            // デバッグ無効化
            debuggable false
        }
    }
}
```

## 8. トラブルシューティング

### よくある問題

#### Deep Linkが動作しない
- AndroidManifest.xmlのintent-filterが正しく設定されているか確認
- パッケージ名が正確に設定されているか確認
- `android:autoVerify="true"`が設定されているか確認

#### 認証が失敗する
- Supabaseの認証設定でカスタムURIスキームが正しく設定されているか確認
- PKCEフローが有効になっているか確認
- インターネット権限が設定されているか確認

#### プッシュ通知が届かない
- Firebase Cloud Messagingの設定が正しいか確認
- 通知権限が許可されているか確認
- FCMトークンが正しく取得できているか確認

### デバッグ方法
```bash
# ログの確認
flutter logs

# デバッグビルド
flutter build apk --debug

# リリースビルド
flutter build apk --release
```

## 使用上の注意
1. **本番環境では必ずHTTPS**を使用
2. **認証情報は適切に管理**し、ソースコードに含めない
3. **深いリンクのセキュリティ**を考慮する
4. **権限の最小化**を心がける
5. **定期的なセキュリティアップデート**を実施