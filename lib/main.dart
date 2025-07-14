import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/vegetable_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 一時的にSupabase初期化をコメントアウト（キーが設定されていないため）
  // await Supabase.initialize(
  //   url: AppConstants.supabaseUrl,
  //   anonKey: AppConstants.supabaseAnonKey,
  // );
  
  runApp(const VegetableTeacherApp());
}

class VegetableTeacherApp extends StatelessWidget {
  const VegetableTeacherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VegetableProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('家庭菜園を始めよう！'),
          ],
        ),
      ),
    );
  }
}