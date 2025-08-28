import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';

class ScheduleAdjustmentService {
  static final ScheduleAdjustmentService _instance = 
      ScheduleAdjustmentService._internal();
  factory ScheduleAdjustmentService() => _instance;
  ScheduleAdjustmentService._internal();

  /// フィードバックに基づいて水やりスケジュールを調整
  Future<void> adjustWateringSchedule({
    required String userVegetableId,
    required String soilCondition,
    String? previousCondition,
  }) async {
    try {
      // 現在の調整データを取得
      final currentData = await _getCurrentAdjustmentData(userVegetableId);
      
      // 新しい調整係数を計算
      final adjustmentFactor = await _calculateAdjustmentFactor(
        userVegetableId: userVegetableId,
        soilCondition: soilCondition,
        currentData: currentData,
      );

      // 調整データを更新
      await _updateScheduleAdjustments(
        userVegetableId: userVegetableId,
        adjustmentFactor: adjustmentFactor,
        soilCondition: soilCondition,
        currentData: currentData,
      );

      debugPrint(
        'Schedule adjusted: $userVegetableId, '
        'condition: $soilCondition, adjustment: $adjustmentFactor',
      );
    } catch (e) {
      debugPrint('Error adjusting schedule: $e');
      rethrow;
    }
  }

  /// 現在のスケジュール調整データを取得
  Future<Map<String, dynamic>> _getCurrentAdjustmentData(
    String userVegetableId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('user_vegetables')
          .select('schedule_adjustments, planted_date')
          .eq('id', userVegetableId)
          .single();

      return {
        'schedule_adjustments': Map<String, dynamic>.from(
          response['schedule_adjustments'] ?? {},
        ),
        'planted_date': response['planted_date'],
      };
    } catch (e) {
      debugPrint('Error getting current adjustment data: $e');
      return {
        'schedule_adjustments': <String, dynamic>{},
        'planted_date': null,
      };
    }
  }

  /// 調整係数を計算
  Future<double> _calculateAdjustmentFactor({
    required String userVegetableId,
    required String soilCondition,
    required Map<String, dynamic> currentData,
  }) async {
    final scheduleAdjustments = currentData['schedule_adjustments'] as Map<String, dynamic>;
    final currentAdjustment = (scheduleAdjustments['watering_interval_adjustment'] as num?)?.toDouble() ?? 0.0;
    
    // 基本調整値
    double baseAdjustment = _getBaseAdjustmentForCondition(soilCondition);
    
    // 季節係数を適用
    double seasonalFactor = await _getSeasonalFactor(userVegetableId);
    
    // 連続フィードバックパターンを分析
    double patternAdjustment = await _analyzePatternAdjustment(userVegetableId, soilCondition);
    
    // 最終的な調整値を計算（段階的調整）
    double targetAdjustment = baseAdjustment * seasonalFactor + patternAdjustment;
    
    // 急激な変化を避けるため、現在値から段階的に調整
    double finalAdjustment = _calculateGradualAdjustment(currentAdjustment, targetAdjustment);
    
    // 調整値の範囲を制限（-50% ～ +100%）
    return finalAdjustment.clamp(-0.5, 1.0);
  }

  /// 土の状態に基づく基本調整値
  double _getBaseAdjustmentForCondition(String soilCondition) {
    switch (soilCondition) {
      case 'カラカラ':
        return -0.2; // 水やり間隔を20%短縮
      case '少し湿ってる':
        return 0.0;  // 調整なし
      case '十分湿ってる':
        return 0.3;  // 水やり間隔を30%延長
      default:
        return 0.0;
    }
  }

  /// 季節係数を取得
  Future<double> _getSeasonalFactor(String userVegetableId) async {
    try {
      final now = DateTime.now();
      final month = now.month;
      
      // 季節による水やり頻度の調整
      // 夏期（6-8月）: より頻繁に
      // 冬期（12-2月）: 頻度を下げる
      // 春秋（3-5月、9-11月）: 標準
      
      if (month >= 6 && month <= 8) {
        // 夏期: 乾燥しやすいため調整を強めに
        return 1.2;
      } else if (month == 12 || month <= 2) {
        // 冬期: 乾燥しにくいため調整を弱めに
        return 0.8;
      } else {
        // 春秋: 標準
        return 1.0;
      }
    } catch (e) {
      debugPrint('Error getting seasonal factor: $e');
      return 1.0;
    }
  }

  /// フィードバックパターンを分析して調整値を計算
  Future<double> _analyzePatternAdjustment(
    String userVegetableId,
    String currentCondition,
  ) async {
    try {
      // 過去1週間のフィードバック履歴を取得
      final recentFeedbacks = await _getRecentFeedbacks(userVegetableId, 7);
      
      if (recentFeedbacks.length < 3) {
        return 0.0; // データ不足の場合は追加調整なし
      }

      // 連続して同じ状態が続く場合の調整
      int consecutiveCount = _countConsecutiveCondition(recentFeedbacks, currentCondition);
      
      if (consecutiveCount >= 3) {
        switch (currentCondition) {
          case 'カラカラ':
            // 連続してカラカラの場合、より強い調整
            return -0.1;
          case '十分湿ってる':
            // 連続して湿っている場合、より強い調整
            return 0.1;
          default:
            return 0.0;
        }
      }
      
      return 0.0;
    } catch (e) {
      debugPrint('Error analyzing pattern adjustment: $e');
      return 0.0;
    }
  }

  /// 最近のフィードバックを取得
  Future<List<Map<String, dynamic>>> _getRecentFeedbacks(
    String userVegetableId,
    int days,
  ) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final response = await SupabaseService.client
          .from('notifications')
          .select('feedback, scheduled_date')
          .eq('user_vegetable_id', userVegetableId)
          .gte('scheduled_date', cutoffDate.toIso8601String().split('T')[0])
          .not('feedback', 'is', null)
          .order('scheduled_date', ascending: false);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting recent feedbacks: $e');
      return [];
    }
  }

  /// 連続する同じ状態の数をカウント
  int _countConsecutiveCondition(
    List<Map<String, dynamic>> feedbacks,
    String targetCondition,
  ) {
    int count = 0;
    
    for (final feedback in feedbacks) {
      final feedbackData = feedback['feedback'] as Map<String, dynamic>?;
      final soilCondition = feedbackData?['soil_condition'] as String?;
      
      if (soilCondition == targetCondition) {
        count++;
      } else {
        break; // 連続性が途切れた
      }
    }
    
    return count;
  }

  /// 段階的調整値の計算
  double _calculateGradualAdjustment(double current, double target) {
    // 現在値から目標値への段階的な移行（一度に最大0.1の変更）
    final difference = target - current;
    final maxChange = 0.1;
    
    if (difference.abs() <= maxChange) {
      return target;
    } else {
      return current + (difference > 0 ? maxChange : -maxChange);
    }
  }

  /// スケジュール調整データを更新
  Future<void> _updateScheduleAdjustments({
    required String userVegetableId,
    required double adjustmentFactor,
    required String soilCondition,
    required Map<String, dynamic> currentData,
  }) async {
    final scheduleAdjustments = currentData['schedule_adjustments'] as Map<String, dynamic>;
    
    // 更新するデータ
    final updatedAdjustments = {
      ...scheduleAdjustments,
      'watering_interval_adjustment': adjustmentFactor,
      'last_feedback_date': DateTime.now().toIso8601String().split('T')[0],
      'last_soil_condition': soilCondition,
      'adjustment_history': _updateAdjustmentHistory(
        scheduleAdjustments['adjustment_history'] as List<dynamic>? ?? [],
        adjustmentFactor,
        soilCondition,
      ),
    };

    await SupabaseService.client
        .from('user_vegetables')
        .update({
          'schedule_adjustments': updatedAdjustments,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userVegetableId);
  }

  /// 調整履歴を更新（最新10件を保持）
  List<Map<String, dynamic>> _updateAdjustmentHistory(
    List<dynamic> currentHistory,
    double adjustment,
    String soilCondition,
  ) {
    final history = List<Map<String, dynamic>>.from(
      currentHistory.cast<Map<String, dynamic>>(),
    );
    
    // 新しい履歴を追加
    history.insert(0, {
      'date': DateTime.now().toIso8601String().split('T')[0],
      'adjustment': adjustment,
      'soil_condition': soilCondition,
    });
    
    // 最新10件のみ保持
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    return history;
  }

  /// 特定の野菜の現在の調整状況を取得
  Future<Map<String, dynamic>?> getCurrentAdjustmentStatus(
    String userVegetableId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('user_vegetables')
          .select('schedule_adjustments')
          .eq('id', userVegetableId)
          .single();

      return response['schedule_adjustments'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting adjustment status: $e');
      return null;
    }
  }

  /// 調整履歴をリセット（必要に応じて）
  Future<void> resetAdjustments(String userVegetableId) async {
    try {
      await SupabaseService.client
          .from('user_vegetables')
          .update({
            'schedule_adjustments': {},
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userVegetableId);

      debugPrint('Schedule adjustments reset for: $userVegetableId');
    } catch (e) {
      debugPrint('Error resetting adjustments: $e');
      rethrow;
    }
  }
}