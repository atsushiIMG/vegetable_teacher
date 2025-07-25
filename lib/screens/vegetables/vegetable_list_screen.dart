import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/vegetable_provider.dart';
import '../../models/user_vegetable.dart';
import '../../models/vegetable.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../widgets/vegetable_icon.dart';

class VegetableListScreen extends StatelessWidget {
  const VegetableListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('やさいせんせい'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<VegetableProvider>(
        builder: (context, vegetableProvider, child) {
          if (vegetableProvider.isLoading && vegetableProvider.growingVegetables.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vegetableProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vegetableProvider.errorMessage!,
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      vegetableProvider.clearError();
                      vegetableProvider.loadUserVegetables();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          final growingVegetables = vegetableProvider.growingVegetables;

          if (growingVegetables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '栽培中の野菜がありません',
                    style: AppTextStyles.headline2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '新しい野菜を育て始めましょう！',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await vegetableProvider.loadUserVegetables();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: growingVegetables.length,
              itemBuilder: (context, index) {
                final userVegetable = growingVegetables[index];
                final vegetable = vegetableProvider.getVegetableById(userVegetable.vegetableId);
                
                return VegetableCard(
                  userVegetable: userVegetable,
                  vegetable: vegetable,
                  onTap: () {
                    context.push('/vegetables/${userVegetable.id}');
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // 既にホーム画面なので何もしない
              break;
            case 1:
              context.push('/vegetables/add');
              break;
            case 2:
              // TODO: 設定画面に遷移
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('設定画面は今後実装予定です'),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '野菜を追加',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class VegetableCard extends StatelessWidget {
  final UserVegetable userVegetable;
  final Vegetable? vegetable;
  final VoidCallback onTap;

  const VegetableCard({
    super.key,
    required this.userVegetable,
    required this.vegetable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 野菜アイコン
              VegetableListIcon(
                vegetableName: vegetable?.name ?? '',
                size: 56,
              ),
              const SizedBox(width: 16),
              
              // 野菜情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vegetable?.name ?? '野菜',
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userVegetable.plantType.displayName} • ${userVegetable.location.displayName}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '栽培開始から${userVegetable.daysSincePlanted}日経過',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 次の作業表示
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getNextTask(vegetable, userVegetable.daysSincePlanted, userVegetable),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _getNextTask(Vegetable? vegetable, int daysSincePlanted, UserVegetable userVegetable) {
    if (vegetable == null) return '作業なし';
    
    // 植えタイプに応じた適切なスケジュールを取得
    final schedule = vegetable.getScheduleForPlantType(userVegetable.plantType);
    
    // 次の作業を見つける
    for (final task in schedule.tasks) {
      if (task.day >= daysSincePlanted) {
        if (task.day == daysSincePlanted) {
          return '今日: ${task.type}';
        } else {
          final daysUntil = task.day - daysSincePlanted;
          return '${daysUntil}日後: ${task.type}';
        }
      }
    }
    
    return '収穫期';
  }
}