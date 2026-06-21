import 'package:flutter/material.dart';
import 'package:dinneer/theme/app_colors.dart';

class EmoteButton extends StatelessWidget {
  final VoidCallback onTap;

  const EmoteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.marfim,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.tinta.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text('😊', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
