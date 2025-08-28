import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../widgets/vegetable_icon.dart';
import '../../services/feedback_service.dart';

enum SoilCondition {
  dry('カラカラ', '💧', '水やりが必要です'),
  moist('少し湿ってる', '✨', '良い状態です'),
  wet('十分湿ってる', '💦', 'しばらく様子見で');

  const SoilCondition(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}

class FeedbackScreen extends StatefulWidget {
  final String notificationId;
  final String vegetableName;
  final String userVegetableId;

  const FeedbackScreen({
    super.key,
    required this.notificationId,
    required this.vegetableName,
    required this.userVegetableId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  SoilCondition? _selectedCondition;
  final TextEditingController _commentController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('土の状態を教えてください'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 野菜情報ヘッダー
            _buildVegetableHeader(),
            const SizedBox(height: 32),
            
            // 土の状態選択
            _buildSoilConditionSelector(),
            const SizedBox(height: 32),
            
            // コメント入力欄
            _buildCommentInput(),
            const SizedBox(height: 40),
            
            // 送信ボタン
            _buildSubmitButton(),
            const SizedBox(height: 16),
            
            // 説明テキスト
            _buildHelpText(),
          ],
        ),
      ),
    );
  }

  Widget _buildVegetableHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          VegetableIcon(
            vegetableName: widget.vegetableName,
            size: 60,
            backgroundColor: AppColors.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          Text(
            widget.vegetableName,
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '水やり後の土の状態はいかがですか？',
            style: AppTextStyles.body1.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSoilConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '土の状態を選択してください',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...SoilCondition.values.map((condition) => _buildConditionCard(condition)),
      ],
    );
  }

  Widget _buildConditionCard(SoilCondition condition) {
    final isSelected = _selectedCondition == condition;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCondition = condition;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1) 
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary 
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 絵文字アイコン
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    condition.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // テキスト情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition.displayName,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      condition.description,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 選択マーク
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'コメント（任意）',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: '野菜の様子や気になることがあれば...',
              hintStyle: AppTextStyles.body1.copyWith(
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: AppTextStyles.caption.copyWith(
                color: Colors.grey[500],
              ),
            ),
            style: AppTextStyles.body1,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedCondition != null && !_isSubmitting;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'フィードバックを送信',
                style: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'あなたのフィードバックで次回の水やりタイミングが調整されます',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (_selectedCondition == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _feedbackService.submitFeedback(
        notificationId: widget.notificationId,
        userVegetableId: widget.userVegetableId,
        soilCondition: _selectedCondition!.displayName,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'フィードバックを送信しました！',
                  style: AppTextStyles.body1.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // 少し遅延してから画面を閉じる
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'フィードバックの送信に失敗しました',
                  style: AppTextStyles.body1.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}