import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);
  double _wateringFrequency = 1.0; // 1.0 = 標準、0.5 = 少なめ、1.5 = 多め
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      // 朝の通知時間（デフォルト7:00）
      final morningHour = prefs.getInt('morning_hour') ?? 7;
      final morningMinute = prefs.getInt('morning_minute') ?? 0;
      _morningTime = TimeOfDay(hour: morningHour, minute: morningMinute);
      
      // 夕方の通知時間（デフォルト18:00）
      final eveningHour = prefs.getInt('evening_hour') ?? 18;
      final eveningMinute = prefs.getInt('evening_minute') ?? 0;
      _eveningTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);
      
      // 水やり頻度（デフォルト1.0）
      _wateringFrequency = prefs.getDouble('watering_frequency') ?? 1.0;
      
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('morning_hour', _morningTime.hour);
    await prefs.setInt('morning_minute', _morningTime.minute);
    await prefs.setInt('evening_hour', _eveningTime.hour);
    await prefs.setInt('evening_minute', _eveningTime.minute);
    await prefs.setDouble('watering_frequency', _wateringFrequency);
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
            title: '朝の通知時間',
            subtitle: '朝の作業（水やり、観察など）の通知時間',
            time: _morningTime,
            onTimeSelected: (time) {
              setState(() {
                _morningTime = time;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 8),
          _buildTimeTile(
            title: '夕方の通知時間',
            subtitle: '夕方の作業（追肥、支柱立てなど）の通知時間',
            time: _eveningTime,
            onTimeSelected: (time) {
              setState(() {
                _eveningTime = time;
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