import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:myboss_mobile/features/chat/domain/entities/chat_message.dart';

class NativeChatView extends StatefulWidget {
  const NativeChatView({
    super.key,
    required this.contact,
    required this.currentUserId,
  });

  final ChatContact contact;
  final String currentUserId;

  @override
  State<NativeChatView> createState() => _NativeChatViewState();
}

class _NativeChatViewState extends State<NativeChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _loading = true;
  bool _sending = false;
  String? _since;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = _messages.isEmpty);
    }

    try {
      final response = await getIt<ChatRemoteDataSource>().getMessages(
        peerId: widget.contact.id,
        since: silent ? _since : null,
      );
      final incoming = response.map(ChatMessage.fromJson).toList();
      if (!mounted) return;

      setState(() {
        if (incoming.isNotEmpty) {
          final existingIds = _messages.map((m) => m.id).toSet();
          for (final message in incoming) {
            if (!existingIds.contains(message.id)) {
              _messages.add(message);
            }
          }
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _since = _messages.last.createdAt.toIso8601String();
        }
        _loading = false;
      });
      if (incoming.isNotEmpty) _scrollToBottom();
    } catch (e) {
      if (mounted && !silent) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorNetwork)),
        );
      }
    }
  }

  void _startPolling() {
    Future<void>.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      await _loadMessages(silent: true);
      _startPolling();
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    try {
      final sent = await getIt<ChatRemoteDataSource>().sendMessage(
        recipientId: widget.contact.id,
        text: text,
      );
      if (!mounted) return;
      final message = ChatMessage.fromJson(sent);
      setState(() {
        if (!_messages.any((m) => m.id == message.id)) {
          _messages.add(message);
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _since = _messages.last.createdAt.toIso8601String();
        }
        _sending = false;
      });
      _scrollToBottom();
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (mounted) await _loadMessages(silent: true);
    } catch (_) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorNetwork)),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    }

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.chatEmptyHintDirect(widget.contact.name),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey600, height: 1.4),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _ChatBubble(
                    message: _messages[index],
                    currentUserId: widget.currentUserId,
                  ),
                ),
        ),
        Material(
          elevation: 8,
          color: AppColors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.chatTypeMessage,
                        filled: true,
                        fillColor: AppColors.grey100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    style: IconButton.styleFrom(backgroundColor: AppColors.orange),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Icon(Icons.send_rounded, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.currentUserId});

  final ChatMessage message;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine(currentUserId);
    final alignment = isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart;
    final color = isMine ? AppColors.orange : AppColors.grey100;
    final textColor = isMine ? AppColors.white : AppColors.black;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine && message.senderName != null && message.senderName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName!,
                  style: TextStyle(color: textColor.withValues(alpha: 0.75), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            Text(message.text, style: TextStyle(color: textColor, height: 1.35)),
          ],
        ),
      ),
    );
  }
}
