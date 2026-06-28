import 'package:flutter/material.dart';

class FloatingChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingChatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: onTap,
        child: const Icon(Icons.chat),
      ),
    );
  }
}