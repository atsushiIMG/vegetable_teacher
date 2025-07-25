import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/vegetable_provider.dart';
import '../../models/vegetable.dart';
import '../../models/user_vegetable.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../widgets/vegetable_icon.dart';

class AddVegetableScreen extends StatefulWidget {
  const AddVegetableScreen({super.key});

  @override
  State<AddVegetableScreen> createState() => _AddVegetableScreenState();
}

class _AddVegetableScreenState extends State<AddVegetableScreen> {
  Vegetable? _selectedVegetable;
  DateTime _plantedDate = DateTime.now();
  PlantType _plantType = PlantType.seed;
  LocationType _location = LocationType.pot;
  bool _isPhotoMode = false;
  String? _photoId;
  
  final _photoIdController = TextEditingController();

  @override
  void dispose() {
    _photoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('野菜を追加'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<VegetableProvider>(
        builder: (context, vegetableProvider, child) {
          if (vegetableProvider.isLoading && vegetableProvider.vegetables.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vegetableProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '野菜データの読み込みエラー',
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      vegetableProvider.errorMessage!,
                      style: AppTextStyles.body1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      vegetableProvider.clearError();
                      vegetableProvider.loadVegetables();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          if (vegetableProvider.vegetables.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '野菜データがありません',
                    style: AppTextStyles.headline3,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'データベースに野菜データが見つかりません',
                    style: AppTextStyles.body1,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ステップ1: 野菜選択
                _buildSectionHeader('1. 育てる野菜を選択'),
                const SizedBox(height: 12),
                _buildVegetableGrid(vegetableProvider.vegetables),
                
                const SizedBox(height: 32),
                
                // ステップ2: 基本情報
                _buildSectionHeader('2. 基本情報を入力'),
                const SizedBox(height: 16),
                
                // 植えた日
                _buildDatePicker(),
                const SizedBox(height: 20),
                
                // 種/苗選択
                _buildPlantTypeSelector(),
                const SizedBox(height: 20),
                
                // 鉢/畑選択
                _buildLocationSelector(),
                const SizedBox(height: 32),
                
                // ステップ3: オプション設定（フェーズ2用）
                _buildSectionHeader('3. オプション設定'),
                const SizedBox(height: 16),
                _buildPhotoModeToggle(),
                
                const SizedBox(height: 32),
                
                // 登録ボタン
                _buildAddButton(vegetableProvider),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.headline3.copyWith(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildVegetableGrid(List<Vegetable> vegetables) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        final vegetable = vegetables[index];
        final isSelected = _selectedVegetable?.id == vegetable.id;
        
        return VegetableSelectionCard(
          vegetable: vegetable,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedVegetable = vegetable;
            });
          },
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '植えた日',
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: _plantedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              setState(() {
                _plantedDate = selectedDate;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_plantedDate.year}年${_plantedDate.month}月${_plantedDate.day}日',
                  style: AppTextStyles.body1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '種類',
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: PlantType.values.map((type) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type == PlantType.seed ? 8 : 0,
                  left: type == PlantType.seedling ? 8 : 0,
                ),
                child: RadioListTile<PlantType>(
                  title: Text(type.displayName),
                  value: type,
                  groupValue: _plantType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _plantType = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '栽培場所',
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: LocationType.values.map((location) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: location == LocationType.pot ? 8 : 0,
                  left: location == LocationType.field ? 8 : 0,
                ),
                child: RadioListTile<LocationType>(
                  title: Text(location.displayName),
                  value: location,
                  groupValue: _location,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _location = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoModeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(
            '撮影モード',
            style: AppTextStyles.subtitle2,
          ),
          subtitle: const Text(
            '成長記録を写真で残します（フェーズ2機能）',
            style: AppTextStyles.caption,
          ),
          value: _isPhotoMode,
          onChanged: (value) {
            setState(() {
              _isPhotoMode = value;
              if (!value) {
                _photoId = null;
                _photoIdController.clear();
              }
            });
          },
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        if (_isPhotoMode) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _photoIdController,
            decoration: const InputDecoration(
              labelText: '撮影ID（例: トマト#1）',
              hintText: '野菜名#番号',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _photoId = value.isEmpty ? null : value;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAddButton(VegetableProvider vegetableProvider) {
    final canAdd = _selectedVegetable != null;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canAdd && !vegetableProvider.isLoading
            ? () => _addVegetable(vegetableProvider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: vegetableProvider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '栽培を開始する',
                style: AppTextStyles.button,
              ),
      ),
    );
  }

  Future<void> _addVegetable(VegetableProvider vegetableProvider) async {
    if (_selectedVegetable == null) return;

    final success = await vegetableProvider.addUserVegetable(
      vegetableId: _selectedVegetable!.id,
      plantedDate: _plantedDate,
      plantType: _plantType,
      location: _location,
      isPhotoMode: _isPhotoMode,
      photoId: _photoId,
    );

    if (success && mounted) {
      context.pop(true); // 成功を示すために true を返す
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vegetableProvider.errorMessage ?? '野菜の追加に失敗しました',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class VegetableSelectionCard extends StatelessWidget {
  final Vegetable vegetable;
  final bool isSelected;
  final VoidCallback onTap;

  const VegetableSelectionCard({
    super.key,
    required this.vegetable,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VegetableSelectionIcon(
                vegetableName: vegetable.name,
                isSelected: isSelected,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                vegetable.name,
                style: AppTextStyles.body2.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

}