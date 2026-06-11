import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Soft gradient mesh background matching the web `Background` component.
class DlssBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const DlssBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEEF2FF),
                Color(0xFFFFFFFF),
                Color(0xFFF8FAFC),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        if (showBlobs) ...[
          Positioned(
            top: -60,
            left: -40,
            child: _blob(
              180,
              [AppTheme.primaryColor.withValues(alpha: 0.18), AppTheme.secondaryColor.withValues(alpha: 0.12)],
            ),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: _blob(
              150,
              [AppTheme.tertiaryColor.withValues(alpha: 0.16), AppTheme.errorColor.withValues(alpha: 0.08)],
            ),
          ),
          Positioned(
            bottom: -80,
            left: 80,
            child: _blob(
              200,
              [AppTheme.successColor.withValues(alpha: 0.12), AppTheme.secondaryColor.withValues(alpha: 0.1)],
            ),
          ),
        ],
        child,
      ],
    );
  }

  Widget _blob(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
