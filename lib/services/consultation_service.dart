import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ai_chat_service.dart';

class ConsultationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 相談履歴を保存
  Future<void> saveChatHistory({
    required String userVegetableId,
    required List<ChatMessage> messages,
  }) async {
    try {
      final messagesJson = messages.map((msg) => msg.toJson()).toList();
      
      await _supabase.from('consultations').upsert({
        'user_vegetable_id': userVegetableId,
        'messages': messagesJson,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('相談履歴の保存に失敗しました: $e');
    }
  }

  /// 相談履歴を取得
  Future<List<ChatMessage>> getChatHistory(String userVegetableId) async {
    try {
      final response = await _supabase
          .from('consultations')
          .select('messages')
          .eq('user_vegetable_id', userVegetableId)
          .maybeSingle();

      if (response == null || response['messages'] == null) {
        return [];
      }

      final messagesJson = response['messages'] as List<dynamic>;
      return messagesJson
          .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('相談履歴の取得に失敗しました: $e');
    }
  }

  /// 相談履歴を削除
  Future<void> deleteChatHistory(String userVegetableId) async {
    try {
      await _supabase
          .from('consultations')
          .delete()
          .eq('user_vegetable_id', userVegetableId);
    } catch (e) {
      throw Exception('相談履歴の削除に失敗しました: $e');
    }
  }
}