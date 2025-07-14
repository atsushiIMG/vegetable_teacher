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
  
  // Supabase初期化
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey.isNotEmpty 
        ? AppConstants.supabaseAnonKey 
        : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNzcmZua2Fub2VnbWZsZ2N2a3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEzMDQ5MjUsImV4cCI6MjAzNjg4MDkyNX0.7y2JBmCrJ8l5bJBmhNgKCqfIVfNyEqhVOlXJrGJ8TfM',
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

