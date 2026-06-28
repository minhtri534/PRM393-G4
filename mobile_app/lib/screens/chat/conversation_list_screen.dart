import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/chat/conversation_tile.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        final data = provider.conversations;

        return Column(
          children: [
            const DlssPageHeader(
              title: "Chat",
              subtitle: "All conversations",
            ),

            Expanded(
              child: _buildBody(provider, data),
            )
          ],
        );
      },
    );
  }

  Widget _buildBody(ChatProvider provider, List data) {
    if (provider.loading && provider.conversations.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (data.isEmpty) {
      return const Center(child: Text("No conversations"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final conv = data[index];

        return ConversationTile(
          conversation: conv,
          onTap: () async {
            await context.read<ChatProvider>().openConversation(conv.id);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatScreen(),
              ),
            );
          },
        );
      },
    );
  }
}