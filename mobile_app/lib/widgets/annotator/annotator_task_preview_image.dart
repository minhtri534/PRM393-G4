import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AnnotatorTaskPreviewImage extends StatelessWidget {
  final Uint8List? imageBytes;

  const AnnotatorTaskPreviewImage({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          imageBytes!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: AppTheme.textHintColor,
      ),
    );
  }
}
