import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:flutter/material.dart';
import '../screens/tela_detalhes_jantar.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class CardRefeicao extends StatelessWidget {
  final Cardapio refeicao;
  final VoidCallback? onRecarregar;

  const CardRefeicao({super.key, required this.refeicao, this.onRecarregar});

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
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.marfim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.bordaSuave),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 112,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _imagem(),
                    if (refeicao.categoria != null)
                      Positioned(top: 8, left: 8, child: _tag(refeicao.categoria!)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        refeicao.nmCardapio,
                        style: AppTypography.serif(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _infoAnfitriao(),
                      const SizedBox(height: 4),
                      _linhaInfo(Icons.calendar_today_rounded, refeicao.dataCurta),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: refeicao.precoFormatado,
                              style: AppTypography.serif(
                                fontSize: 16,
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
                          _linhaInfo(
                            Icons.people_alt_rounded,
                            '${refeicao.nuConvidadosConfirmados}/${refeicao.nuMaxConvidados}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagem() {
    final tem = refeicao.urlFoto != null && refeicao.urlFoto!.isNotEmpty;
    return tem
        ? CachedNetworkImage(
            imageUrl: refeicao.urlFoto!,
            fit: BoxFit.cover,
            placeholder: (_, _) => _fallback(),
            errorWidget: (_, _, _) => _fallback(),
          )
        : _fallback();
  }

  Widget _fallback() {
    return Container(
      color: AppColors.terracotaSuave,
      child: const Center(
        child: Icon(Icons.restaurant_rounded,
            color: AppColors.terracota, size: 38),
      ),
    );
  }

  Widget _tag(String categoria) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tan,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        categoria,
        style: AppTypography.sans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.tanTexto,
        ),
      ),
    );
  }

  Widget _linhaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.bege),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: AppTypography.sans(fontSize: 12, color: AppColors.bege),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _infoAnfitriao() {
    final temFoto = refeicao.urlFotoAnfitriao != null &&
        refeicao.urlFotoAnfitriao!.isNotEmpty;
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: AppColors.tan,
          backgroundImage:
              temFoto ? NetworkImage(refeicao.urlFotoAnfitriao!) : null,
          child: temFoto
              ? null
              : const Icon(Icons.person, size: 12, color: AppColors.tanTexto),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Chef ${refeicao.nmUsuarioAnfitriao}',
            style: AppTypography.sans(fontSize: 12, color: AppColors.tinta),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
