import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool estaCarregando;
  final Color corFundo;
  final Color corTexto;

  final bool larguraTotal;

  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.estaCarregando = false,
    this.corFundo = AppColors.terracota,
    this.corTexto = Colors.white,
    this.larguraTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    final botao = ElevatedButton(
      onPressed: estaCarregando ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: corFundo,
        foregroundColor: corTexto,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: estaCarregando
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: corTexto, strokeWidth: 2),
            )
          : Text(
              texto,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
    );

    if (!larguraTotal) return botao;
    return SizedBox(width: double.infinity, child: botao);
  }
}
