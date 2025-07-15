import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/vegetable_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数からSupabaseキーを取得
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: AppConstants.supabaseUrl,
  );
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // APIキーの存在チェック
  if (supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_ANON_KEY is not configured. '
      'Please set the environment variable or use --dart-define during build.',
    );
  }
  
  // Supabase初期化
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
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

