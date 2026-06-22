import 'package:flutter/material.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class InfoAnfitriao extends StatelessWidget {
  final String nomeAnfitriao;
  final String? urlFotoAnfitriao;

  const InfoAnfitriao({
    super.key,
    required this.nomeAnfitriao,
    required this.urlFotoAnfitriao,
  });

  @override
  Widget build(BuildContext context) {
    final bool temFoto =
        urlFotoAnfitriao != null && urlFotoAnfitriao!.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.tan,
          backgroundImage: temFoto ? NetworkImage(urlFotoAnfitriao!) : null,
          child: !temFoto
              ? const Icon(Icons.person, color: AppColors.tanTexto)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Anfitrião",
              style: AppTypography.sans(fontSize: 12, color: AppColors.bege),
            ),
            Text(
              nomeAnfitriao,
              style: AppTypography.serif(fontSize: 16),
            ),
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
