import 'package:flutter/foundation.dart';
import '../models/vegetable.dart';
import '../models/user_vegetable.dart';
import '../core/services/supabase_service.dart';

class VegetableProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Vegetable> _vegetables = [];
  List<UserVegetable> _userVegetables = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Vegetable> get vegetables => _vegetables;
  List<UserVegetable> get userVegetables => _userVegetables;
  List<UserVegetable> get growingVegetables => 
      _userVegetables.where((v) => v.status == VegetableStatus.growing).toList();

  VegetableProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadVegetables();
    await loadUserVegetables();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 野菜マスタデータを取得
  Future<void> loadVegetables() async {
    try {
      _setLoading(true);
      final response = await SupabaseService.client
          .from('vegetables')
          .select()
          .order('name');

      if ((response as List).isEmpty) {
        _setError('野菜データがデータベースに存在しません');
        return;
      }

      _vegetables = (response as List)
          .map((data) => Vegetable.fromSupabase(data))
          .toList();
      
      clearError();
    } catch (e) {
      _setError('野菜データの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// ユーザーの栽培記録を取得
  Future<void> loadUserVegetables() async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        _setError('ユーザーがログインしていません');
        return;
      }

      _setLoading(true);
      final response = await SupabaseService.client
          .from('user_vegetables')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _userVegetables = (response as List)
          .map((data) => UserVegetable.fromSupabase(data))
          .toList();
      
      clearError();
    } catch (e) {
      _setError('栽培記録の読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 新しい野菜の栽培を開始
  Future<bool> addUserVegetable({
    required String vegetableId,
    required DateTime plantedDate,
    required PlantType plantType,
    required LocationType location,
    bool isPhotoMode = false,
    String? photoId,
  }) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        _setError('ユーザーがログインしていません');
        return false;
      }

      _setLoading(true);
      
      final now = DateTime.now();
      final data = {
        'user_id': userId,
        'vegetable_id': vegetableId,
        'planted_date': plantedDate.toIso8601String().split('T')[0],
        'plant_type': plantType.displayName,
        'location': location.displayName,
        'is_photo_mode': isPhotoMode,
        'photo_id': photoId,
        'status': VegetableStatus.growing.value,
        'schedule_adjustments': {},
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await SupabaseService.client
          .from('user_vegetables')
          .insert(data);

      await loadUserVegetables(); // リロード
      clearError();
      return true;
    } catch (e) {
      _setError('野菜の追加に失敗しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 栽培記録を更新
  Future<bool> updateUserVegetable(UserVegetable userVegetable) async {
    try {
      _setLoading(true);
      
      final updatedData = userVegetable.toSupabase();
      updatedData['updated_at'] = DateTime.now().toIso8601String();

      await SupabaseService.client
          .from('user_vegetables')
          .update(updatedData)
          .eq('id', userVegetable.id);

      await loadUserVegetables(); // リロード
      clearError();
      return true;
    } catch (e) {
      _setError('栽培記録の更新に失敗しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 栽培記録を削除
  Future<bool> deleteUserVegetable(String userVegetableId) async {
    try {
      _setLoading(true);
      
      await SupabaseService.client
          .from('user_vegetables')
          .delete()
          .eq('id', userVegetableId);

      await loadUserVegetables(); // リロード
      clearError();
      return true;
    } catch (e) {
      _setError('栽培記録の削除に失敗しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 特定の野菜マスタデータを取得
  Vegetable? getVegetableById(String vegetableId) {
    try {
      return _vegetables.firstWhere((v) => v.id == vegetableId);
    } catch (e) {
      return null;
    }
  }

  /// 収穫に変更
  Future<bool> harvestVegetable(String userVegetableId) async {
    final userVegetable = _userVegetables.firstWhere(
      (v) => v.id == userVegetableId,
    );
    
    return updateUserVegetable(
      userVegetable.copyWith(status: VegetableStatus.harvested),
    );
  }

  /// アーカイブに変更
  Future<bool> archiveVegetable(String userVegetableId) async {
    final userVegetable = _userVegetables.firstWhere(
      (v) => v.id == userVegetableId,
    );
    
    return updateUserVegetable(
      userVegetable.copyWith(status: VegetableStatus.archived),
    );
  }
}