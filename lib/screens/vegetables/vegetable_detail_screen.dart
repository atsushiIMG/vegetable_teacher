import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vegetable_provider.dart';
import '../../models/user_vegetable.dart';
import '../../models/vegetable.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../widgets/vegetable_icon.dart';

class VegetableDetailScreen extends StatefulWidget {
  final String userVegetableId;

  const VegetableDetailScreen({
    super.key,
    required this.userVegetableId,
  });

  @override
  State<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends State<VegetableDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VegetableProvider>(
      builder: (context, vegetableProvider, child) {
        final userVegetable = vegetableProvider.userVegetables
            .where((v) => v.id == widget.userVegetableId)
            .firstOrNull;

        if (userVegetable == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('野菜詳細'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('野菜が見つかりません'),
            ),
          );
        }

        final vegetable = vegetableProvider.getVegetableById(userVegetable.vegetableId);

        return Scaffold(
          appBar: AppBar(
            title: Text(vegetable?.name ?? '野菜詳細'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleMenuAction(value, vegetableProvider, userVegetable);
                },
                itemBuilder: (context) => [
                  if (userVegetable.status == VegetableStatus.growing) ...[
                    const PopupMenuItem(
                      value: 'harvest',
                      child: Row(
                        children: [
                          Icon(Icons.agriculture, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('収穫完了'),
                        ],
                      ),
                    ),
                  ],
                  if (userVegetable.status == VegetableStatus.harvested) ...[
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('アーカイブ'),
                        ],
                      ),
                    ),
                  ],
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('削除'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー情報
                _buildHeader(userVegetable, vegetable),
                
                // 次の作業
                _buildNextTask(userVegetable, vegetable),
                
                // 栽培スケジュール
                _buildSchedule(userVegetable, vegetable),
                
                // 栽培のコツ
                if (vegetable?.growingTips != null)
                  _buildTips(vegetable!.growingTips!),
                
                // よくある問題
                if (vegetable?.commonProblems != null)
                  _buildProblems(vegetable!.commonProblems!),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // TODO: AI相談画面に遷移
              print('AI相談画面に遷移');
            },
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.chat),
            label: const Text('AI相談'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserVegetable userVegetable, Vegetable? vegetable) {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.1),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 野菜アイコン
          VegetableIcon(
            vegetableName: vegetable?.name ?? '',
            size: 80,
            backgroundColor: AppColors.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          
          // 基本情報
          Text(
            vegetable?.name ?? '野菜',
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(userVegetable.plantType.displayName),
              const SizedBox(width: 8),
              _buildInfoChip(userVegetable.location.displayName),
              if (userVegetable.isPhotoMode) ...[
                const SizedBox(width: 8),
                _buildInfoChip('📸 ${userVegetable.photoId ?? '撮影モード'}'),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // 栽培日数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '栽培開始から${userVegetable.daysSincePlanted}日経過',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNextTask(UserVegetable userVegetable, Vegetable? vegetable) {
    final nextTask = _getNextTask(vegetable, userVegetable.daysSincePlanted, userVegetable);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '次の作業',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (nextTask != null) ...[
            Text(
              nextTask.type,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 8),
            Text(
              nextTask.description,
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getTaskTiming(nextTask, userVegetable.daysSincePlanted),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              '収穫期です！',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '美味しく実った野菜を収穫しましょう',
              style: AppTextStyles.body1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedule(UserVegetable userVegetable, Vegetable? vegetable) {
    if (vegetable == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '栽培スケジュール',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 16),
          
          ...vegetable.getScheduleForPlantType(userVegetable.plantType).tasks.map((task) {
            final isPast = task.day < userVegetable.daysSincePlanted;
            final isCurrent = task.day == userVegetable.daysSincePlanted;
            final isFuture = task.day > userVegetable.daysSincePlanted;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイムライン
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isPast 
                              ? AppColors.success
                              : isCurrent
                                  ? AppColors.primary
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPast 
                              ? Icons.check 
                              : isCurrent 
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                          color: isPast || isCurrent ? Colors.white : Colors.grey[600],
                          size: 16,
                        ),
                      ),
                      if (task != vegetable.getScheduleForPlantType(userVegetable.plantType).tasks.last)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // タスク情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${task.day}日目',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isPast 
                                    ? AppColors.success.withOpacity(0.1)
                                    : isCurrent
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.type,
                                style: AppTextStyles.caption.copyWith(
                                  color: isPast 
                                      ? AppColors.success
                                      : isCurrent
                                          ? AppColors.primary
                                          : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: AppTextStyles.body2.copyWith(
                            color: isFuture ? Colors.grey[600] : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTips(String tips) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '栽培のコツ',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tips,
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Widget _buildProblems(String problems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'よくある問題',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            problems,
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  VegetableTask? _getNextTask(Vegetable? vegetable, int daysSincePlanted, UserVegetable userVegetable) {
    if (vegetable == null) return null;
    
    // 植えタイプに応じた適切なスケジュールを取得
    final schedule = vegetable.getScheduleForPlantType(userVegetable.plantType);
    
    for (final task in schedule.tasks) {
      if (task.day >= daysSincePlanted) {
        return task;
      }
    }
    return null;
  }

  String _getTaskTiming(VegetableTask task, int daysSincePlanted) {
    if (task.day == daysSincePlanted) {
      return '今日が実施日です';
    } else if (task.day > daysSincePlanted) {
      final daysUntil = task.day - daysSincePlanted;
      return 'あと${daysUntil}日後';
    } else {
      return '実施済み';
    }
  }


  Future<void> _handleMenuAction(
    String action,
    VegetableProvider vegetableProvider,
    UserVegetable userVegetable,
  ) async {
    switch (action) {
      case 'harvest':
        final success = await vegetableProvider.harvestVegetable(userVegetable.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('収穫完了にしました！'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        break;
        
      case 'archive':
        final success = await vegetableProvider.archiveVegetable(userVegetable.id);
        if (success && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('アーカイブに移動しました'),
            ),
          );
        }
        break;
        
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('削除確認'),
            content: const Text('この栽培記録を削除しますか？\n削除すると元に戻せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('削除'),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          final success = await vegetableProvider.deleteUserVegetable(userVegetable.id);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('栽培記録を削除しました'),
              ),
            );
          }
        }
        break;
    }
  }
}