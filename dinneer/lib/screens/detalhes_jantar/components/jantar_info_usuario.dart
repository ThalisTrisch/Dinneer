import 'package:flutter/material.dart';

class JantarInfoUsuario extends StatelessWidget {
  final String? urlFotoAnfitriao;
  final String nmUsuarioAnfitriao;

  const JantarInfoUsuario({
    super.key,
    required this.urlFotoAnfitriao,
    required this.nmUsuarioAnfitriao,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              (urlFotoAnfitriao != null && urlFotoAnfitriao!.isNotEmpty)
              ? NetworkImage(urlFotoAnfitriao!)
              : null,
          child: (urlFotoAnfitriao == null || urlFotoAnfitriao!.isEmpty)
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
              nmUsuarioAnfitriao,
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
