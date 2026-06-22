import 'package:flutter/material.dart';
import 'package:dinneer/theme/app_colors.dart';

import 'app_bar_clipper.dart';

class CabecalhoImagemJantar extends StatelessWidget {
  final String? urlFoto;

  const CabecalhoImagemJantar({super.key, required this.urlFoto});

  @override
  Widget build(BuildContext context) {
    final bool temFoto = urlFoto != null && urlFoto!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 280.0,
      backgroundColor: AppColors.creme,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipPath(
          clipper: AppBarClipper(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.terracotaSuave,
              image: temFoto
                  ? DecorationImage(
                      image: NetworkImage(urlFoto!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !temFoto
                ? const Icon(Icons.restaurant, size: 100, color: AppColors.terracota)
                : null,
          ),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.marfim,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.tinta),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
