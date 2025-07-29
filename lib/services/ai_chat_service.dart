import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_vegetable.dart';

class AiChatService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 2);

  late final String _apiKey;
  DateTime? _lastRequestTime;

  AiChatService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in environment variables');
    }
  }

  Future<String> sendMessage({
    required String message,
    required UserVegetable userVegetable,
    required List<ChatMessage> chatHistory,
  }) async {
    // レート制限対策：前回のリクエストから最低2秒待つ
    await _enforceRateLimit();

    Exception? lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': _buildMessages(message, userVegetable, chatHistory),
            'max_tokens': 1000,
            'temperature': 0.7,
          }),
        );

        _lastRequestTime = DateTime.now();

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          return data['choices'][0]['message']['content'] as String;
        } else if (response.statusCode == 429) {
          // レート制限エラーの場合
          final retryAfter = _getRetryAfterSeconds(response.headers);
          final delay = Duration(
            seconds: retryAfter ?? (2 << attempt),
          ); // 指数バックオフ

          if (attempt < _maxRetries - 1) {
            await Future.delayed(delay);
            continue;
          } else {
            throw RateLimitException(
              'APIのレート制限に達しました。しばらく時間をおいてから再試行してください。',
              retryAfter: retryAfter,
            );
          }
        } else {
          final errorData = jsonDecode(response.body);
          throw ApiException(
            'OpenAI API error: ${response.statusCode}',
            statusCode: response.statusCode,
            errorMessage: errorData['error']?['message'] ?? 'Unknown error',
          );
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (e is RateLimitException || e is ApiException) {
          rethrow; // 特定のエラーはそのまま再スロー
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

  int? _getRetryAfterSeconds(Map<String, String> headers) {
    final retryAfter = headers['retry-after'];
    if (retryAfter != null) {
      return int.tryParse(retryAfter);
    }
    return null;
  }

  List<Map<String, String>> _buildMessages(
    String userMessage,
    UserVegetable userVegetable,
    List<ChatMessage> chatHistory,
  ) {
    final messages = <Map<String, String>>[];

    // システムプロンプト
    messages.add({
      'role': 'system',
      'content': _buildSystemPrompt(userVegetable),
    });

    // 過去の会話履歴を追加
    for (final chat in chatHistory) {
      if (chat.message.isNotEmpty) {
        messages.add({
          'role': chat.isUser ? 'user' : 'assistant',
          'content': chat.message,
        });
      }
    }

    // 現在のユーザーメッセージ
    messages.add({'role': 'user', 'content': userMessage});

    return messages;
  }

  String _buildSystemPrompt(UserVegetable userVegetable) {
    final plantedDays = userVegetable.daysSincePlanted;
    final plantType = userVegetable.plantType.displayName;
    final location = userVegetable.location.displayName;

    return '''
あなたは家庭菜園の専門家です。初心者にも分かりやすく、親しみやすい口調でアドバイスをしてください。

栽培情報：
- 植付タイプ: $plantType
- 栽培場所: $location
- 植えてからの日数: $plantedDays日

回答の指針：
1. 具体的で実践的なアドバイスを提供する
2. 初心者でも理解しやすい言葉を使う
3. 必要に応じて作業のタイミングや手順を説明する
4. 症状がある場合は、可能な原因と対処法を複数提示する
5. 安全性を重視し、農薬等の使用は慎重に案内する
6. 150文字以内で簡潔に回答する

口調：
- 丁寧だが親しみやすい
- 「〜です」「〜ますね」などの敬語
- 「きっと」「おそらく」など、断定を避ける表現を適度に使う
''';
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

class RateLimitException implements Exception {
  final String message;
  final int? retryAfter;

  RateLimitException(this.message, {this.retryAfter});

  @override
  String toString() => message;
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
