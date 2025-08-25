import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class SupabaseNotificationService {
  static final SupabaseNotificationService _instance =
      SupabaseNotificationService._internal();
  factory SupabaseNotificationService() => _instance;
  SupabaseNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  RealtimeChannel? _notificationChannel;

  // 初期化
  Future<void> initialize() async {
    try {
      // 通知権限の確認・要求
      if (!_isInitialized) {
        await _requestNotificationPermissions();

        // ローカル通知初期化
        await _initializeLocalNotifications();
      }

      // Supabase リアルタイム通知の設定（ユーザーがログイン済みの場合は常に実行）
      await _initializeRealtimeNotifications();

      _isInitialized = true;
    } catch (e) {
      debugPrint('SupabaseNotificationService initialization failed: $e');
      rethrow;
    }
  }

  // 通知権限の要求
  Future<bool> _requestNotificationPermissions() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  // 通知権限の状態を確認
  Future<PermissionStatus> getNotificationPermissionStatus() async {
    return await Permission.notification.status;
  }

  // 通知権限が許可されているかチェック
  Future<bool> hasNotificationPermission() async {
    final status = await getNotificationPermissionStatus();
    return status.isGranted;
  }

  // ローカル通知の初期化
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android通知チャンネル作成
    await _createNotificationChannels();
  }

  // 通知チャンネル作成
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel vegetableTasksChannel =
        AndroidNotificationChannel(
          'vegetable_tasks',
          'やさいのお世話',
          description: '野菜のお世話のタイミングをお知らせします',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          'general',
          '一般通知',
          description: 'アプリからの一般的なお知らせ',
          importance: Importance.defaultImportance,
        );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(vegetableTasksChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(generalChannel);
  }

  // Supabase リアルタイム通知の初期化
  Future<void> _initializeRealtimeNotifications() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      return;
    }

    // 既存のチャネルがあれば閉じる
    if (_notificationChannel != null) {
      await _notificationChannel!.unsubscribe();
      _notificationChannel = null;
    }

    // 通知テーブルの変更を監視（UPDATEイベントでsent_atが設定された時）
    _notificationChannel =
        SupabaseService.client
            .channel('notifications_${user.id}') // チャンネル名を修正
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'notifications',
              callback: _onNotificationReceived,
            )
            .subscribe();
  }

  // リアルタイム通知受信時の処理
  void _onNotificationReceived(PostgresChangePayload payload) {
    try {
      final notification = payload.newRecord;
      if (notification != null) {
        // 現在のユーザーの通知かチェック
        final currentUser = SupabaseService.currentUser;
        if (currentUser != null &&
            _isNotificationForCurrentUser(notification, currentUser.id)) {
          _showLocalNotificationFromData(notification);
        }
      }
    } catch (e) {
      debugPrint('Error processing notification: $e');
    }
  }

  // 通知が現在のユーザーのものかチェック
  bool _isNotificationForCurrentUser(
    Map<String, dynamic> notification,
    String userId,
  ) {
    // RLSによりユーザーに関連する通知のみが送信されるはずですが、追加チェック
    final notificationUserId = notification['user_id'] as String?;
    return notificationUserId == userId;
  }

  // データからローカル通知を表示
  Future<void> _showLocalNotificationFromData(Map<String, dynamic> data) async {
    final taskType = data['task_type'] as String?;
    final description = data['description'] as String?;
    final vegetableName = data['vegetable_name'] as String?;
    final id = data['id'];

    // 必須フィールドチェック
    if (taskType == null || description == null || id == null) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'vegetable_tasks',
          'やさいのお世話',
          channelDescription: '野菜のお世話のタイミングをお知らせします',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title =
        vegetableName != null
            ? '🌱 ${vegetableName}のお世話時間です'
            : '🌱 やさいのお世話時間です';

    try {
      await _localNotifications.show(
        id.hashCode,
        title,
        description,
        platformDetails,
        payload: jsonEncode(data),
      );
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }

  // 通知タップ時の処理
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationData(data);
    }
  }

  // 通知データの処理
  void _handleNotificationData(Map<String, dynamic> data) {
    final userVegetableId = data['user_vegetable_id'];

    if (userVegetableId != null) {
      // 野菜詳細画面に遷移
      // TODO: ナビゲーション処理を実装
    }
  }

  // 通知設定の更新
  Future<void> updateNotificationSettings({
    required bool enabled,
    TimeOfDay? notificationTime,
    bool? weekendNotifications,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // 現在の設定を取得
      final currentSettings = await getNotificationSettings();

      // JSONB形式で設定を構築
      final notificationSettings = <String, dynamic>{
        // 既存の設定を保持
        'watering_reminders': currentSettings?['watering_reminders'] ?? true,
        'task_reminders': currentSettings?['task_reminders'] ?? true,
        'harvest_reminders': currentSettings?['harvest_reminders'] ?? true,
        'general_tips': currentSettings?['general_tips'] ?? true,
        // 新しい設定を更新
        'notification_enabled': enabled,
      };

      if (notificationTime != null) {
        notificationSettings['notification_time'] =
            '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}:00';
      }

      if (weekendNotifications != null) {
        notificationSettings['weekend_notifications'] = weekendNotifications;
      }

      // 専用関数を使用して更新
      await SupabaseService.client.rpc(
        'update_notification_settings',
        params: {'p_user_id': user.id, 'p_settings': notificationSettings},
      );
    } catch (e) {
      debugPrint('Failed to update notification settings: $e');
      rethrow;
    }
  }

  // 通知設定の取得
  Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        return null;
      }

      // 専用関数を使用して設定を取得
      final response = await SupabaseService.client.rpc(
        'get_user_notification_settings',
        params: {'p_user_id': user.id},
      );

      // JSONB形式のレスポンスを返す
      if (response != null) {
        return Map<String, dynamic>.from(response as Map);
      }

      return null;
    } catch (e) {
      debugPrint('Failed to get notification settings: $e');
      return null;
    }
  }

  // 手動で通知をチェック（プルリフレッシュ用）
  Future<List<Map<String, dynamic>>> checkPendingNotifications() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await SupabaseService.client
          .from('notifications')
          .select('*, user_vegetables!inner(vegetable:vegetables(name))')
          .eq('scheduled_date', today)
          .isFilter('sent_at', null)
          .order('created_at', ascending: false);

      final notifications = response as List<dynamic>;

      // ローカル通知として表示
      for (final notification in notifications) {
        final vegetableName =
            notification['user_vegetables']?['vegetable']?['name'];
        final notificationData = Map<String, dynamic>.from({
          ...notification,
          'vegetable_name': vegetableName,
        });
        await _showLocalNotificationFromData(notificationData);
      }

      return notifications.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to check pending notifications: $e');
      return [];
    }
  }

  // テスト通知の送信
  Future<void> sendTestNotification() async {
    // 初期化状態をチェック
    if (!_isInitialized) {
      await initialize();
    }

    // 通知権限をチェック
    final hasPermission = await hasNotificationPermission();
    if (!hasPermission) {
      throw Exception('通知権限が許可されていません。設定で通知を有効にしてください。');
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'vegetable_tasks',
          'やさいのお世話',
          channelDescription: '野菜のお世話のタイミングをお知らせします',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        999,
        '🌱 テスト通知',
        'やさいせんせいの通知が正常に動作しています',
        platformDetails,
      );
    } catch (e) {
      debugPrint('Failed to send test notification: $e');
      rethrow;
    }
  }

  // 通知履歴を取得
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    int limit = 50,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final response = await SupabaseService.client
          .from('notifications')
          .select('*, user_vegetables!inner(vegetable:vegetables(name))')
          .order('scheduled_date', ascending: false)
          .limit(limit);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to get notification history: $e');
      return [];
    }
  }

  // リソースクリーンアップ
  void dispose() {
    _notificationChannel?.unsubscribe();
    _isInitialized = false;
  }

  // 初期化状態を取得
  bool get isInitialized => _isInitialized;
}
