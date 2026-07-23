import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/notification/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/dlss_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh();
    });
  }

  IconData _iconFor(NotificationModel n) {
    if (n.isChatMessage) return Icons.chat_bubble_outline;
    if (n.isProjectAssigned) return Icons.person_add_alt_1_outlined;
    return Icons.campaign_outlined;
  }

  String _timeLabel(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (!provider.hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllRead(),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.state == NotificationLoadState.loading &&
              provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.items.isEmpty) {
            return const DlssEmptyState(
              icon: Icons.notifications_none_outlined,
              message: 'No notifications yet',
              hint: 'Chat messages and project updates will show up here.',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = provider.items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: n.isRead
                        ? AppTheme.surfaceSoftColor
                        : AppTheme.primaryColor.withValues(alpha: 0.12),
                    child: Icon(
                      _iconFor(n),
                      color: n.isRead
                          ? AppTheme.textHintColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (n.body != null && n.body!.isNotEmpty)
                        Text(
                          n.body!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (n.projectName != null && n.projectName!.isNotEmpty)
                            n.projectName!,
                          _timeLabel(n.createdAt),
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textHintColor,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: n.body != null && n.body!.isNotEmpty,
                  onTap: () => provider.markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
