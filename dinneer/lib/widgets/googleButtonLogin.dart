import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLoginButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.tinta,
          backgroundColor: AppColors.marfim,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.bordaSuave),
          ),
        ),
        icon: Image.asset(
          'assets/images/google_logo.png',
          height: 22.0,
        ),
        label: Text(
          'Continuar com o Google',
          style: AppTypography.sans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.tinta,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
