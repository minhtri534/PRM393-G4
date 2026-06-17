import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

enum DlssCardVariant { elevated, glass }

class DlssCard extends StatelessWidget {
  final Widget child;
  final DlssCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderSide? topAccent;
  final bool fillHeight;

  const DlssCard({
    super.key,
    required this.child,
    this.variant = DlssCardVariant.elevated,
    this.padding,
    this.onTap,
    this.topAccent,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppConstants.borderRadiusMedium);
    final backgroundColor = variant == DlssCardVariant.glass
        ? Colors.white.withValues(alpha: 0.72)
        : AppTheme.backgroundColor;

    final content = Column(
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topAccent != null && topAccent!.style != BorderStyle.none)
          Container(
            height: topAccent!.width,
            color: topAccent!.color,
          ),
        if (fillHeight)
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
              child: child,
            ),
          )
        else
          Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
            child: child,
          ),
      ],
    );

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: content,
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: card,
      ),
    );
  }
}
