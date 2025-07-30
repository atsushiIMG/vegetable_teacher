import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 通知設定セクション
          _buildSectionHeader('通知設定'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: '通知設定',
            subtitle: '作業タイミングや水やりの通知を調整',
            onTap: () {
              context.push('/settings/notification');
            },
          ),
          const SizedBox(height: 24),

          // アカウント設定セクション
          _buildSectionHeader('アカウント'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'プライバシー設定',
            subtitle: 'データの取り扱いとプライバシー',
            onTap: () {
              _showPrivacyDialog(context);
            },
          ),
          const SizedBox(height: 24),
          
          // データ管理セクション
          _buildSectionHeader('データ管理'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.delete_outline,
            title: 'データ削除',
            subtitle: 'すべての栽培記録を削除',
            isDestructive: true,
            onTap: () {
              _showDataDeleteDialog(context);
            },
          ),
          const SizedBox(height: 24),

          // アプリ情報セクション
          _buildSectionHeader('アプリ情報'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'アプリについて',
            subtitle: 'バージョン情報とサポート',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'ヘルプ',
            subtitle: '使い方とよくある質問',
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          const SizedBox(height: 24),

          // アカウント操作
          _buildSectionHeader('アカウント操作'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.person_remove_outlined,
            title: 'アカウント削除',
            subtitle: 'アカウントを完全に削除',
            isDestructive: true,
            onTap: () {
              _showAccountDeleteDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: 'ログアウト',
            subtitle: 'アカウントからログアウトします',
            isDestructive: true,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.headline3.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('やさいせんせいについて'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('バージョン: 1.0.0'),
            SizedBox(height: 8),
            Text('家庭菜園初心者向けの栽培管理アプリです。'),
            SizedBox(height: 8),
            Text('適切なタイミングで作業を通知し、AIに相談もできます。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ヘルプ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基本的な使い方:'),
            SizedBox(height: 8),
            Text('1. 野菜を追加して栽培を開始'),
            Text('2. 通知に従って作業を実施'),
            Text('3. 分からないことはAIに相談'),
            SizedBox(height: 16),
            Text('問題が発生した場合は、アプリを再起動してみてください。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プライバシー設定'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('データの取り扱いについて:'),
            SizedBox(height: 8),
            Text('• 栽培記録はお客様のアカウントに紐づいて安全に保存されます'),
            Text('• AI相談の内容は回答品質向上のためのみに使用されます'),
            Text('• 個人情報は第三者に提供されることはありません'),
            SizedBox(height: 16),
            Text(
              '詳細なプライバシーポリシーは今後提供予定です。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showDataDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ削除'),
        content: const Text(
          'すべての栽培記録が削除されます。この操作は取り消せません。\n\n'
          '本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('データ削除機能は今後実装予定です'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showAccountDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'アカウントを完全に削除します。すべてのデータが失われ、この操作は取り消せません。\n\n'
          '本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('アカウント削除機能は今後実装予定です'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }
}