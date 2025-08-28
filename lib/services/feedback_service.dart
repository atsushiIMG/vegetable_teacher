import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import 'schedule_adjustment_service.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  /// フィードバックを送信
  Future<void> submitFeedback({
    required String notificationId,
    required String userVegetableId,
    required String soilCondition,
    String? comment,
  }) async {
    try {
      // 入力値のバリデーション
      _validateFeedbackData(
        notificationId: notificationId,
        userVegetableId: userVegetableId,
        soilCondition: soilCondition,
      );

      // フィードバックデータの作成
      final feedbackData = <String, dynamic>{
        'soil_condition': soilCondition,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      // コメントがある場合は追加
      if (comment != null && comment.isNotEmpty) {
        feedbackData['comment'] = comment;
      }

      // Supabaseに保存
      await SupabaseService.client
          .from('notifications')
          .update({
            'feedback': feedbackData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      // スケジュール調整サービスを呼び出し
      await _adjustWateringSchedule(
        userVegetableId: userVegetableId,
        soilCondition: soilCondition,
      );

      debugPrint('Feedback submitted successfully for notification: $notificationId');
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      rethrow;
    }
  }

  /// フィードバックデータのバリデーション
  void _validateFeedbackData({
    required String notificationId,
    required String userVegetableId,
    required String soilCondition,
  }) {
    if (notificationId.isEmpty) {
      throw ArgumentError('通知IDが無効です');
    }

    if (userVegetableId.isEmpty) {
      throw ArgumentError('野菜IDが無効です');
    }

    if (soilCondition.isEmpty) {
      throw ArgumentError('土の状態を選択してください');
    }

    // 有効な土の状態の確認
    const validConditions = ['カラカラ', '少し湿ってる', '十分湿ってる'];
    if (!validConditions.contains(soilCondition)) {
      throw ArgumentError('無効な土の状態です: $soilCondition');
    }
  }

  /// 水やりスケジュールの調整
  Future<void> _adjustWateringSchedule({
    required String userVegetableId,
    required String soilCondition,
  }) async {
    try {
      // 高度なスケジュール調整サービスを使用
      final adjustmentService = ScheduleAdjustmentService();
      await adjustmentService.adjustWateringSchedule(
        userVegetableId: userVegetableId,
        soilCondition: soilCondition,
      );
    } catch (e) {
      debugPrint('Error adjusting watering schedule: $e');
      // スケジュール調整のエラーはフィードバック送信を阻害しないよう、
      // ここでは例外を再throw しない
    }
  }


  /// 特定の通知のフィードバックを取得
  Future<Map<String, dynamic>?> getFeedback(String notificationId) async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select('feedback')
          .eq('id', notificationId)
          .single();

      return response['feedback'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting feedback: $e');
      return null;
    }
  }

  /// 特定の野菜の最近のフィードバック履歴を取得
  Future<List<Map<String, dynamic>>> getFeedbackHistory({
    required String userVegetableId,
    int limit = 10,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select('id, task_type, scheduled_date, feedback, sent_at')
          .eq('user_vegetable_id', userVegetableId)
          .not('feedback', 'is', null)
          .order('scheduled_date', ascending: false)
          .limit(limit);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting feedback history: $e');
      return [];
    }
  }

  /// 土の状態の統計情報を取得（分析用）
  Future<Map<String, int>> getSoilConditionStats(String userVegetableId) async {
    try {
      final feedbackHistory = await getFeedbackHistory(
        userVegetableId: userVegetableId,
        limit: 30, // 過去30件
      );

      final stats = <String, int>{
        'カラカラ': 0,
        '少し湿ってる': 0,
        '十分湿ってる': 0,
      };

      for (final feedback in feedbackHistory) {
        final feedbackData = feedback['feedback'] as Map<String, dynamic>?;
        if (feedbackData != null) {
          final soilCondition = feedbackData['soil_condition'] as String?;
          if (soilCondition != null && stats.containsKey(soilCondition)) {
            stats[soilCondition] = stats[soilCondition]! + 1;
          }
        }
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting soil condition stats: $e');
      return {
        'カラカラ': 0,
        '少し湿ってる': 0,
        '十分湿ってる': 0,
      };
    }
  }
}