import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:flutter/material.dart';
import '../screens/tela_detalhes_jantar.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class CardDestaque extends StatelessWidget {
  final Cardapio refeicao;
  final VoidCallback? onRecarregar;

  const CardDestaque({super.key, required this.refeicao, this.onRecarregar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhesJantar(refeicao: refeicao),
          ),
        );
        if (result == true) onRecarregar?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.marfim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.bordaSuave),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _imagem(),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.62),
                        ],
                      ),
                    ),
                  ),
                ),
                if (refeicao.categoria != null)
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: _tag(refeicao.categoria!),
                  ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        refeicao.nmCardapio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.serif(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _chef(),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 15, color: AppColors.bege),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            refeicao.dataCurta,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                                fontSize: 12, color: AppColors.bege),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.people_alt_rounded,
                            size: 15, color: AppColors.bege),
                        const SizedBox(width: 5),
                        Text(
                          '${refeicao.nuConvidadosConfirmados}/${refeicao.nuMaxConvidados}',
                          style: AppTypography.sans(
                              fontSize: 12, color: AppColors.bege),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  RichText(
                    text: TextSpan(
                      text: refeicao.precoFormatado,
                      style: AppTypography.serif(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terracota,
                      ),
                      children: [
                        TextSpan(
                          text: ' /pessoa',
                          style: AppTypography.sans(
                              fontSize: 11, color: AppColors.bege),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagem() {
    final tem = refeicao.urlFoto != null && refeicao.urlFoto!.isNotEmpty;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: tem
          ? CachedNetworkImage(
              imageUrl: refeicao.urlFoto!,
              fit: BoxFit.cover,
              placeholder: (_, _) => _fallback(),
              errorWidget: (_, _, _) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.terracotaSuave,
      child: const Center(
        child: Icon(Icons.restaurant_rounded,
            color: AppColors.terracota, size: 56),
      ),
    );
  }

  Widget _tag(String categoria) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tan,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        categoria.toUpperCase(),
        style: AppTypography.sans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.tanTexto,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _chef() {
    final temFoto = refeicao.urlFotoAnfitriao != null &&
        refeicao.urlFotoAnfitriao!.isNotEmpty;
    return Row(
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: Colors.white24,
          backgroundImage:
              temFoto ? NetworkImage(refeicao.urlFotoAnfitriao!) : null,
          child: temFoto
              ? null
              : const Icon(Icons.person, size: 13, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Chef ${refeicao.nmUsuarioAnfitriao}',
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
