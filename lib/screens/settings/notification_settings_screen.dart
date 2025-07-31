import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../services/supabase_notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _weekendNotifications = true;
  double _wateringFrequency = 1.0; // 1.0 = 標準、0.5 = 少なめ、1.5 = 多め
  bool _isLoading = true;
  final SupabaseNotificationService _notificationService = SupabaseNotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // NotificationServiceから設定を取得
      final settings = await _notificationService.getNotificationSettings();
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        if (settings != null) {
          _notificationsEnabled = settings['notification_enabled'] ?? true;
          _weekendNotifications = settings['weekend_notifications'] ?? true;
          
          // 通知時間の解析
          final timeString = settings['notification_time'] as String?;
          if (timeString != null) {
            final parts = timeString.split(':');
            if (parts.length >= 2) {
              final hour = int.tryParse(parts[0]) ?? 9;
              final minute = int.tryParse(parts[1]) ?? 0;
              _notificationTime = TimeOfDay(hour: hour, minute: minute);
            }
          }
        }
        
        // 水やり頻度はローカルストレージから取得
        _wateringFrequency = prefs.getDouble('watering_frequency') ?? 1.0;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定の読み込みに失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      // NotificationServiceに設定を保存
      await _notificationService.updateNotificationSettings(
        enabled: _notificationsEnabled,
        notificationTime: _notificationTime,
        weekendNotifications: _weekendNotifications,
      );
      
      // 水やり頻度はローカルストレージに保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('watering_frequency', _wateringFrequency);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定の保存に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('通知設定'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 通知の有効/無効
          _buildSectionHeader('基本設定'),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: 'プッシュ通知',
            subtitle: '作業タイミングの通知を受け取る',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 24),

          // 通知時間設定
          _buildSectionHeader('通知時間'),
          const SizedBox(height: 8),
          _buildTimeTile(
            title: '通知時間',
            subtitle: '作業タイミングの通知を受け取る時間',
            time: _notificationTime,
            onTimeSelected: (time) {
              setState(() {
                _notificationTime = time;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: '週末通知',
            subtitle: '土日も通知を受け取る',
            value: _weekendNotifications,
            onChanged: (value) {
              setState(() {
                _weekendNotifications = value;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 24),

          // 水やり頻度調整
          _buildSectionHeader('水やり設定'),
          const SizedBox(height: 8),
          _buildFrequencyTile(),
          const SizedBox(height: 24),

          // テスト通知ボタン
          _buildSectionHeader('テスト'),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: AppColors.primary,
              ),
              title: Text(
                'テスト通知を送信',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '通知が正常に動作するかテストします',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              trailing: const Icon(Icons.send),
              onTap: () async {
                try {
                  await _notificationService.sendTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('テスト通知を送信しました'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('テスト通知の送信に失敗しました'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // 説明テキスト
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '通知について',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• 野菜の種類や成長段階に応じて適切なタイミングで通知されます\n'
                  '• 水やり頻度は季節や天候も考慮して調整されます\n'
                  '• 通知後のフィードバックで次回の通知タイミングが調整されます',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time.format(context),
            style: AppTextStyles.body1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () async {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: time,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (selectedTime != null) {
            onTimeSelected(selectedTime);
          }
        },
      ),
    );
  }

  Widget _buildFrequencyTile() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '水やり頻度',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '基本頻度からの調整（土の乾燥具合や季節に応じて）',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '少なめ',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _wateringFrequency,
                    min: 0.5,
                    max: 1.5,
                    divisions: 4,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _wateringFrequency = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _saveSettings();
                    },
                  ),
                ),
                Text(
                  '多め',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                _getFrequencyLabel(_wateringFrequency),
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyLabel(double frequency) {
    if (frequency <= 0.6) return '少なめ（乾燥気味）';
    if (frequency <= 0.8) return 'やや少なめ';
    if (frequency <= 1.2) return '標準';
    if (frequency <= 1.4) return 'やや多め';
    return '多め（湿潤気味）';
  }
}