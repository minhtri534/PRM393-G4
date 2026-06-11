import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import 'dlss_background.dart';

class DlssNavDestination {
  final String label;
  final IconData icon;
  final Widget body;

  const DlssNavDestination({
    required this.label,
    required this.icon,
    required this.body,
  });
}

class DlssDashboardScaffold extends StatefulWidget {
  final String roleTitle;
  final IconData roleIcon;
  final List<DlssNavDestination> destinations;
  final Widget? floatingActionButton;
  final Widget Function(int index)? fabBuilder;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  const DlssDashboardScaffold({
    super.key,
    required this.roleTitle,
    required this.roleIcon,
    required this.destinations,
    this.floatingActionButton,
    this.fabBuilder,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<DlssDashboardScaffold> createState() => _DlssDashboardScaffoldState();
}

class _DlssDashboardScaffoldState extends State<DlssDashboardScaffold> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant DlssDashboardScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex;
    }
  }

  void _setIndex(int value) {
    setState(() => _index = value);
    widget.onIndexChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().userProfile?.email ?? '';
    final fullName = context.watch<AuthProvider>().userProfile?.fullName ?? 'User';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return DlssBackground(
      showBlobs: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.85),
          surfaceTintColor: Colors.transparent,
          title: Text(widget.destinations[_index].label),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (_) => false,
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.tertiaryColor],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.roleIcon, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'DLSS',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$email • ${widget.roleTitle}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < widget.destinations.length; i++)
                      ListTile(
                        leading: Icon(
                          widget.destinations[i].icon,
                          color: _index == i
                              ? AppTheme.primaryColor
                              : AppTheme.textHintColor,
                        ),
                        title: Text(widget.destinations[i].label),
                        selected: _index == i,
                        selectedTileColor:
                            AppTheme.primaryColor.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          _setIndex(i);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: widget.destinations[_index].body,
        bottomNavigationBar: widget.destinations.length > 1
            ? NavigationBar(
                selectedIndex: _index,
                backgroundColor: Colors.white.withValues(alpha: 0.92),
                indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                onDestinationSelected: _setIndex,
                destinations: [
                  for (final d in widget.destinations)
                    NavigationDestination(icon: Icon(d.icon), label: d.label),
                ],
              )
            : null,
        floatingActionButton:
            widget.fabBuilder?.call(_index) ?? widget.floatingActionButton,
      ),
    );
  }
}
