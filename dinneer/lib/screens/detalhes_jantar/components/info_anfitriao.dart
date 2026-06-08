import 'package:flutter/material.dart';

/// Linha com avatar, nome do anfitrião e avaliação (estrelas).
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
          backgroundColor: Colors.grey[300],
          backgroundImage: temFoto ? NetworkImage(urlFotoAnfitriao!) : null,
          child: !temFoto
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Anfitrião",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              nomeAnfitriao,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
