import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_vegetable.dart';
import '../models/vegetable.dart';

class AiChatService {
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 2);

  final SupabaseClient _supabase = Supabase.instance.client;
  DateTime? _lastRequestTime;

  AiChatService();

  Future<String> sendMessage({
    required String message,
    required UserVegetable userVegetable,
    required Vegetable? vegetable,
    required List<ChatMessage> chatHistory,
  }) async {
    // レート制限対策：前回のリクエストから最低2秒待つ
    await _enforceRateLimit();

    Exception? lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await _supabase.functions.invoke(
          'ai-consultation',
          body: {
            'vegetable_type': vegetable?.name ?? '野菜',
            'message': message,
            'user_vegetable_id': userVegetable.id,
            'planted_days': userVegetable.daysSincePlanted,
            'plant_type': userVegetable.plantType.displayName,
            'location': userVegetable.location.displayName,
            'current_stage': _getCurrentGrowthStage(userVegetable, vegetable),
            'growing_tips': vegetable?.growingTips ?? '',
            'common_problems': vegetable?.commonProblems ?? '',
            'chat_history': chatHistory.map((chat) => chat.toJson()).toList(),
          },
        );

        _lastRequestTime = DateTime.now();

        if (response.status == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          return data['response'] as String;
        } else if (response.status == 429) {
          // Rate limit exceeded
          final retryAfter = response.data?['retry_after'] as int?;
          throw RateLimitException(
            'API rate limit exceeded',
            retryAfter: retryAfter,
          );
        } else {
          throw ApiException(
            'Edge Function error: ${response.status}',
            statusCode: response.status ?? 500,
            errorMessage: response.data?['error'] ?? 'Unknown error',
          );
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (e is ApiException || e is RateLimitException) {
          rethrow; // APIエラーとレート制限エラーはそのまま再スロー
        }

        if (attempt < _maxRetries - 1) {
          await Future.delayed(Duration(seconds: 2 << attempt)); // 指数バックオフ
          continue;
        }
      }
    }

    throw lastException ?? Exception('AI相談でエラーが発生しました');
  }

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _baseDelay) {
        await Future.delayed(_baseDelay - timeSinceLastRequest);
      }
    }
  }

  String _getCurrentGrowthStage(
    UserVegetable userVegetable,
    Vegetable? vegetable,
  ) {
    if (vegetable == null) return '成長中';

    final schedule = vegetable.getScheduleForPlantType(userVegetable.plantType);
    final daysSincePlanted = userVegetable.daysSincePlanted;

    // 現在の日数に最も近いタスクを見つける
    VegetableTask? currentTask;
    for (final task in schedule.tasks) {
      if (task.day <= daysSincePlanted) {
        currentTask = task;
      } else {
        break;
      }
    }

    if (currentTask != null) {
      return '${currentTask.type}期（${currentTask.day}日目以降）';
    } else {
      return '発芽・初期成長期';
    }
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String errorMessage;

  ApiException(
    this.message, {
    required this.statusCode,
    required this.errorMessage,
  });

  @override
  String toString() => '$message: $errorMessage';
}

class RateLimitException implements Exception {
  final String message;
  final int? retryAfter;

  RateLimitException(
    this.message, {
    this.retryAfter,
  });

  @override
  String toString() => message;
}
