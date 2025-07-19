import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // アプリロゴとタイトル
                  Column(
                    children: [
                      Icon(
                        Icons.eco,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'やさいせんせい',
                        style: AppTextStyles.headline1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '家庭菜園を始めよう',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // エラーメッセージ表示
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (authProvider.errorMessage != null)
                    const SizedBox(height: 16),
                  
                  // Googleログインボタン
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleGoogleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Googleでログイン',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 説明テキスト
                  Text(
                    'Googleアカウントでログインして、\nやさいせんせいを始めましょう',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      context.go('/home');
    }
  }
}