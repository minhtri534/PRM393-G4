import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum ActionButtonVariant { primary, gradient, outline, ghost }

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final ActionButtonVariant variant;
  final double? width;
  final double height;
  final IconData? icon;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.variant = ActionButtonVariant.primary,
    this.width,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = isOutlined
        ? ActionButtonVariant.outline
        : variant;

    if (resolvedVariant == ActionButtonVariant.gradient) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.tertiaryColor],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _buildContent(Colors.white),
          ),
        ),
      );
    }

    if (resolvedVariant == ActionButtonVariant.ghost) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          minimumSize: Size(width ?? double.infinity, height),
        ),
        child: _buildContent(AppTheme.primaryColor),
      );
    }

    if (resolvedVariant == ActionButtonVariant.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
          side: const BorderSide(color: AppTheme.borderColor),
          foregroundColor: AppTheme.textPrimaryColor,
        ),
        child: _buildContent(AppTheme.textPrimaryColor),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width ?? double.infinity, height),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      child: _buildContent(Colors.white),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
