import 'package:flutter/material.dart';

import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class DetalhesAdicionais extends StatelessWidget {
  final Cardapio refeicao;

  const DetalhesAdicionais({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.marfim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordaSuave),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoRow(icon: Icons.calendar_today, text: refeicao.dataFormatada),
          Container(width: 1, height: 24, color: AppColors.bordaSuave),
          _InfoRow(
            icon: Icons.people_alt_outlined,
            text:
                '${refeicao.nuConvidadosConfirmados}/${refeicao.nuMaxConvidados} vagas',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.terracota),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.sans(
            color: AppColors.tinta,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
