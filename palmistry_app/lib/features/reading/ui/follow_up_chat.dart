import 'package:flutter/material.dart';

import '../../../app/di.dart';
import '../../../core/models/enums.dart';
import '../../../data/local/database.dart';
import '../../../data/remote/claude_api_client.dart';
import '../services/prompt_builder.dart';

class FollowUpChatSheet extends StatefulWidget {
  final int scanId;
  final String palmShape;
  final String hand;

  const FollowUpChatSheet({
    super.key,
    required this.scanId,
    required this.palmShape,
    required this.hand,
  });

  @override
  State<FollowUpChatSheet> createState() => _FollowUpChatSheetState();
}

class _FollowUpChatSheetState extends State<FollowUpChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _db = getIt<AppDatabase>();
  final _claude = getIt<ClaudeApiClient>();

  List<ScanMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final msgs = await _db.messageDao.getMessagesForScan(widget.scanId);
    if (mounted) {
      setState(() => _messages = msgs);
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() => _isLoading = true);

    // Save user message
    await _db.messageDao.insertMessage(
      ScanMessagesCompanion.insert(
        scanId: widget.scanId,
        role: MessageRole.user.name,
        content: text,
      ),
    );

    // Build messages list for API
    final allMsgs = await _db.messageDao.getMessagesForScan(widget.scanId);
    final apiMessages = allMsgs
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    try {
      final response = await _claude.getFollowUp(
        systemPrompt: PromptBuilder.buildSystemPrompt,
        messages: apiMessages,
      );

      await _db.messageDao.insertMessage(
        ScanMessagesCompanion.insert(
          scanId: widget.scanId,
          role: MessageRole.assistant.name,
          content: response,
        ),
      );
    } catch (e) {
      await _db.messageDao.insertMessage(
        ScanMessagesCompanion.insert(
          scanId: widget.scanId,
          role: MessageRole.assistant.name,
          content: 'Извините, произошла ошибка. Попробуйте ещё раз.',
        ),
      );
    }

    await _loadMessages();
    if (mounted) setState(() => _isLoading = false);
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
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Задать вопрос хироманту',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),

              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) =>
                            _MessageBubble(message: _messages[i]),
                      ),
              ),

              // Loading indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Хиромант думает...',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // Input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ваш вопрос...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0F0F1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C3AED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 48),
          SizedBox(height: 16),
          Text(
            'Задайте вопрос о своей ладони',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Например: «Что означает моя линия сердца?»',
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ScanMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF7C3AED)
              : const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.white.withAlpha(230),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
