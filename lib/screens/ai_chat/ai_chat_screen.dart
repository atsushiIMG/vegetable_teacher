import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_vegetable.dart';
import '../../models/vegetable.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../services/ai_chat_service.dart';
import '../../services/consultation_service.dart';
import '../../providers/vegetable_provider.dart';

class AiChatScreen extends StatefulWidget {
  final UserVegetable userVegetable;

  const AiChatScreen({super.key, required this.userVegetable});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _aiChatService = AiChatService();
  final ConsultationService _consultationService = ConsultationService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _canSend = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatHistory() async {
    try {
      final chatHistory = await _consultationService.getChatHistory(
        widget.userVegetable.id,
      );

      setState(() {
        if (chatHistory.isEmpty) {
          // VegetableProviderから野菜名を取得
          final vegetableProvider = Provider.of<VegetableProvider>(
            context,
            listen: false,
          );
          final vegetable = vegetableProvider.getVegetableById(
            widget.userVegetable.vegetableId,
          );
          final vegetableName = vegetable?.name ?? '野菜';
          final plantedDays = widget.userVegetable.daysSincePlanted;

          _messages = [
            ChatMessage(
              message:
                  'こんにちは！$vegetableNameの栽培についてサポートします。植えてから$plantedDays日目ですね。栽培で気になることがあれば何でもお聞きください！',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ];
        } else {
          _messages = chatHistory;
        }
      });
    } catch (e) {
      setState(() {
        _messages = [
          ChatMessage(
            message: 'こんにちは！栽培についてサポートします。何でもお聞きください！',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || !_canSend) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          message: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
      _canSend = false;
    });

    _scrollToBottom();

    try {
      // VegetableProviderから野菜情報を取得
      final vegetableProvider = Provider.of<VegetableProvider>(
        context,
        listen: false,
      );
      final vegetable = vegetableProvider.getVegetableById(
        widget.userVegetable.vegetableId,
      );

      final response = await _aiChatService.sendMessage(
        message: userMessage,
        userVegetable: widget.userVegetable,
        vegetable: vegetable,
        chatHistory:
            _messages
                .where((msg) => !msg.message.startsWith('こんにちは！'))
                .toList(),
      );

      setState(() {
        _messages.add(
          ChatMessage(
            message: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();

      // 相談履歴を保存
      await _saveChatHistory();

      // 送信可能状態に戻す（3秒後）
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _canSend = true;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _handleError(e);

      // エラー時も一定時間後に送信可能にする
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _canSend = true;
          });
        }
      });
    }
  }

  void _handleError(dynamic error) {
    String message;
    String actionText = 'OK';
    VoidCallback? action;

    if (error is RateLimitException) {
      message = 'APIのレート制限に達しました。';
      if (error.retryAfter != null) {
        message += '\n${error.retryAfter}秒後に再試行してください。';
      } else {
        message += '\nしばらく時間をおいてから再試行してください。';
      }
      actionText = '詳細';
      action = () => _showRateLimitDialog();
    } else if (error is ApiException) {
      message = 'API接続エラーが発生しました。\n再度お試しください。';
    } else {
      message = 'メッセージの送信に失敗しました。\nネットワーク接続を確認してください。';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              error is RateLimitException ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 5),
          action:
              action != null
                  ? SnackBarAction(
                    label: actionText,
                    textColor: Colors.white,
                    onPressed: action,
                  )
                  : null,
        ),
      );
    }
  }

  void _showRateLimitDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 8),
                Text('レート制限について'),
              ],
            ),
            content: const Text(
              'OpenAI APIには利用制限があります。\n\n'
              '対処法：\n'
              '• 2-3分待ってから再試行\n'
              '• 質問を簡潔にまとめる\n'
              '• 連続でメッセージを送らない\n\n'
              'ご理解とご協力をお願いします。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('了解'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveChatHistory() async {
    try {
      await _consultationService.saveChatHistory(
        userVegetableId: widget.userVegetable.id,
        messages: _messages,
      );
    } catch (e) {
      // エラーは無視（バックグラウンドで保存）
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI相談',
          style: AppTextStyles.subtitle1.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.background,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingMessage();
                  }

                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(false),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: AppTextStyles.body2.copyWith(
                      color:
                          message.isUser ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color:
                          message.isUser
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.disabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '回答を生成中...',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isUser ? AppColors.primary : AppColors.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '質問を入力してください...',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.disabled,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isLoading && _canSend,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (_isLoading || !_canSend) ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      (_isLoading || !_canSend)
                          ? AppColors.disabled
                          : AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
