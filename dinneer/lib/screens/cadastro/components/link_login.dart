import 'package:flutter/material.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class LinkLogin extends StatelessWidget {
  const LinkLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Já tem login? ', style: AppTypography.sans(color: AppColors.bege)),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Entre',
            style: AppTypography.sans(
              fontWeight: FontWeight.w600,
              color: AppColors.terracota,
            ),
          ),
        ),
      ],
    );
  }
}
