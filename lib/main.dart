import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/vegetable_provider.dart';
import 'providers/notification_provider.dart';
import 'services/supabase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .envファイルを読み込み
  await dotenv.load(fileName: '.env');
  
  // 環境変数からSupabaseキーを取得（優先順位：--dart-define > .env > デフォルト）
  final supabaseUrl = const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  ).isNotEmpty 
    ? const String.fromEnvironment('SUPABASE_URL')
    : dotenv.env['SUPABASE_URL'] ?? AppConstants.supabaseUrl;
    
  final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
    ? const String.fromEnvironment('SUPABASE_ANON_KEY')
    : dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // APIキーの存在チェック
  if (supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_ANON_KEY is not configured. '
      'Please set the environment variable in .env file or use --dart-define during build.',
    );
  }
  
  // Supabase初期化
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  // Supabase通知サービス初期化
  try {
    await SupabaseNotificationService().initialize();
  } catch (e) {
    print('SupabaseNotificationService initialization failed: $e');
  }
  
  runApp(const VegetableTeacherApp());
}

class VegetableTeacherApp extends StatelessWidget {
  const VegetableTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VegetableProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.createRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

