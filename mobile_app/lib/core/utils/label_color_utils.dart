import 'package:flutter/material.dart';

/// Parses label hex colors used across annotator and reviewer screens.
class LabelColorUtils {
  static Color fromHex(String colorHex) {
    final normalized = colorHex.replaceAll('#', '').trim();
    if (normalized.isEmpty) {
      return Colors.grey;
    }
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
