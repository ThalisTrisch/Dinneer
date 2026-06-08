import 'package:flutter/material.dart';

import 'app_bar_clipper.dart';

/// Cabeçalho (SliverAppBar) com a foto do jantar ou um ícone padrão,
/// recortado pela curva inferior, e o botão de voltar.
class CabecalhoImagemJantar extends StatelessWidget {
  final String? urlFoto;

  const CabecalhoImagemJantar({super.key, required this.urlFoto});

  @override
  Widget build(BuildContext context) {
    final bool temFoto = urlFoto != null && urlFoto!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 280.0,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipPath(
          clipper: AppBarClipper(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: temFoto
                  ? DecorationImage(
                      image: NetworkImage(urlFoto!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !temFoto
                ? const Icon(Icons.restaurant, size: 100, color: Colors.white)
                : null,
          ),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
