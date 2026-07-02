import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat/chat_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../repositories/chat_repository.dart';

class ChatRoomScreen extends StatefulWidget {
  final MyProjectSummaryModel project;

  const ChatRoomScreen({super.key, required this.project});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatRepository = ChatRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChatProvider>().openRoom(
        projectId: widget.project.id,
        projectName: widget.project.name,
      );
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _send() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    final ok = await context.read<ChatProvider>().sendText(text);
    if (ok) _scrollToBottom();
  }

  Future<void> _openAttachment(ChatMessageModel message) async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening attachments is limited on web.')),
      );
      return;
    }
    try {
      final bytes = await _chatRepository.downloadAttachment(message.id);
      if (bytes.isEmpty) return;
      final dir = await getTemporaryDirectory();
      final fileName = message.attachmentFileName ?? 'attachment.bin';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot open attachment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await context.read<ChatProvider>().closeRoom();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.name),
          leading: BackButton(
            onPressed: () async {
              await context.read<ChatProvider>().closeRoom();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: Consumer2<ChatProvider, AuthProvider>(
          builder: (context, provider, auth, _) {
            final currentUserId = auth.userProfile?.id ?? '';
            if (provider.roomState == ChatLoadState.loading &&
                provider.messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.roomState == ChatLoadState.error &&
                provider.messages.isEmpty) {
              return Center(
                child: Text(provider.errorMessage ?? AppConstants.errorGeneric),
              );
            }

            return Column(
              children: [
                if (!provider.realtimeEnabled)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFF7ED),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      provider.errorMessage ??
                          'Realtime offline — messages send via API only.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFECEFF4),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        final message = provider.messages[index];
                        final isMine = message.senderUserId == currentUserId;
                        return _MessageBubble(
                          message: message,
                          isMine: isMine,
                          onOpenAttachment: () => _openAttachment(message),
                        );
                      },
                    ),
                  ),
                ),
                if (provider.errorMessage != null && provider.realtimeEnabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                _Composer(
                  controller: _inputController,
                  isSending: provider.isSending,
                  onSend: _send,
                  onAttach: () async {
                    final ok = await provider.pickAndSendAttachment();
                    if (ok) _scrollToBottom();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;
  final VoidCallback onOpenAttachment;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onOpenAttachment,
  });

  static String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppTheme.primaryColor : Colors.white;
    final textColor = isMine ? Colors.white : AppTheme.textPrimaryColor;
    final subTextColor = isMine
        ? Colors.white.withValues(alpha: 0.85)
        : AppTheme.textHintColor;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMine ? 16 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 16),
    );

    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;

    final bubbleBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isMine) ...[
          Text(
            message.senderFullName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (message.isText && message.content?.trim().isNotEmpty == true)
          Text(
            message.content!,
            style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
          ),
        if (message.isImage) _attachmentBlock(textColor, subTextColor, true),
        if (message.isFile) _attachmentBlock(textColor, subTextColor, false),
        const SizedBox(height: 4),
        Text(
          _formatTime(message.createdAt),
          textAlign: TextAlign.right,
          style: TextStyle(color: subTextColor, fontSize: 10),
        ),
      ],
    );

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: isMine
                ? null
                : Border.all(
                    color: AppTheme.borderColor.withValues(alpha: 0.8),
                  ),
          ),
          child: bubbleBody,
        ),
      ),
    );

    if (isMine) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              message.senderFullName.isNotEmpty
                  ? message.senderFullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          bubble,
        ],
      ),
    );
  }

  Widget _attachmentBlock(Color textColor, Color subTextColor, bool isImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isImage ? Icons.image_outlined : Icons.attach_file,
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              isImage ? 'Image' : (message.attachmentFileName ?? 'File'),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (message.content?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(
            message.content!,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ],
        TextButton(
          onPressed: onOpenAttachment,
          style: TextButton.styleFrom(
            foregroundColor: isMine ? Colors.white : AppTheme.primaryColor,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(isImage ? 'View image' : 'Open file'),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: isSending ? null : onAttach,
              icon: const Icon(Icons.attach_file_outlined),
              color: AppTheme.textSecondaryColor,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: AppTheme.primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isSending ? null : onSend,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
