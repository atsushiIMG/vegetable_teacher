import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/vegetables/vegetable_list_screen.dart';
import '../../screens/vegetables/add_vegetable_screen.dart';
import '../../screens/vegetables/vegetable_detail_screen.dart';
import '../../screens/ai_chat/ai_chat_screen.dart';
import '../../models/user_vegetable.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/notification_settings_screen.dart';
import '../../screens/feedback/feedback_screen.dart';

/// アプリ全体のルーティング設定
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      navigatorKey: GlobalKey<NavigatorState>(),
      routes: [
        // 認証画面
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder:
              (context, state) =>
                  MaterialPage(key: state.pageKey, child: const LoginScreen()),
        ),
        // サインアップ画面は削除されました（Google認証のみ）
        // ホーム画面（野菜一覧画面）
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder:
              (context, state) => MaterialPage(
                key: state.pageKey,
                child: const VegetableListScreen(),
              ),
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        // 野菜追加画面
        GoRoute(
          path: '/vegetables/add',
          name: 'addVegetable',
          pageBuilder:
              (context, state) => MaterialPage(
                key: state.pageKey,
                child: const AddVegetableScreen(),
              ),
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        // 野菜詳細画面
        GoRoute(
          path: '/vegetables/:id',
          name: 'vegetableDetail',
          pageBuilder: (context, state) {
            final userVegetableId = state.pathParameters['id'];

            // IDパラメータの検証
            if (userVegetableId == null || userVegetableId.isEmpty) {
              return MaterialPage(
                key: state.pageKey,
                child: Scaffold(
                  appBar: AppBar(title: const Text('エラー')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '無効なIDです',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('野菜の詳細を表示できませんでした'),
                      ],
                    ),
                  ),
                ),
              );
            }

            return MaterialPage(
              key: state.pageKey,
              child: VegetableDetailScreen(userVegetableId: userVegetableId),
            );
          },
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        // AI相談画面
        GoRoute(
          path: '/vegetables/:id/chat',
          name: 'aiChat',
          pageBuilder: (context, state) {
            final userVegetableId = state.pathParameters['id'];
            final userVegetable = state.extra as UserVegetable?;

            // パラメータの検証
            if (userVegetableId == null ||
                userVegetableId.isEmpty ||
                userVegetable == null) {
              return MaterialPage(
                key: state.pageKey,
                child: Scaffold(
                  appBar: AppBar(title: const Text('エラー')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '野菜情報が見つかりません',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('AI相談を開始できませんでした'),
                      ],
                    ),
                  ),
                ),
              );
            }

            return MaterialPage(
              key: state.pageKey,
              child: AiChatScreen(userVegetable: userVegetable),
            );
          },
        ),
        // 設定画面
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder:
              (context, state) => MaterialPage(
                key: state.pageKey,
                child: const SettingsScreen(),
              ),
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        // 通知設定画面
        GoRoute(
          path: '/settings/notification',
          name: 'notificationSettings',
          pageBuilder:
              (context, state) => MaterialPage(
                key: state.pageKey,
                child: const NotificationSettingsScreen(),
              ),
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        // フィードバック画面
        GoRoute(
          path: '/feedback/:notificationId',
          name: 'feedback',
          pageBuilder: (context, state) {
            final notificationId = state.pathParameters['notificationId'];
            final vegetableName = state.uri.queryParameters['vegetableName'];
            final userVegetableId = state.uri.queryParameters['userVegetableId'];

            // パラメータの検証
            if (notificationId == null ||
                notificationId.isEmpty ||
                vegetableName == null ||
                vegetableName.isEmpty ||
                userVegetableId == null ||
                userVegetableId.isEmpty) {
              return MaterialPage(
                key: state.pageKey,
                child: Scaffold(
                  appBar: AppBar(title: const Text('エラー')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'パラメータが不正です',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('フィードバック画面を表示できませんでした'),
                      ],
                    ),
                  ),
                ),
              );
            }

            return MaterialPage(
              key: state.pageKey,
              child: FeedbackScreen(
                notificationId: notificationId,
                vegetableName: vegetableName,
                userVegetableId: userVegetableId,
              ),
            );
          },
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        // スプラッシュ画面（将来実装）
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder:
              (context, state) =>
                  MaterialPage(key: state.pageKey, child: const SplashScreen()),
        ),
      ],
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticating = state.matchedLocation == '/login';
        final isSplash = state.matchedLocation == '/';

        // スプラッシュ画面はリダイレクト対象外（自身で認証判定を行うため）
        if (isSplash) {
          return null;
        }

        // 認証済みユーザーが認証画面にアクセスしようとした場合、ホームに転送
        if (authProvider.isAuthenticated && isAuthenticating) {
          return '/home';
        }

        // 未認証ユーザーが保護されたページにアクセスしようとした場合、ログイン画面に転送
        if (!authProvider.isAuthenticated && !isAuthenticating) {
          return '/login';
        }

        return null;
      },
      errorPageBuilder:
          (context, state) => MaterialPage(
            key: state.pageKey,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ページが見つかりません',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'URL: ${state.uri}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

/// スプラッシュ画面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // スプラッシュ画面を2秒表示
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'やさいせんせい',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '家庭菜園を始めよう',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
