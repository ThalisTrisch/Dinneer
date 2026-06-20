import 'package:flutter/material.dart';

import 'package:dinneer/service/refeicao/Cardapio.dart';

class DetalhesAdicionais extends StatelessWidget {
  final Cardapio refeicao;

  const DetalhesAdicionais({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoRow(icon: Icons.calendar_today, text: refeicao.dataFormatada),
          Container(width: 1, height: 24, color: Colors.grey[300]),
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
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
