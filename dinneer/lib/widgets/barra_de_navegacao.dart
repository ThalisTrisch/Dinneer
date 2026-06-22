import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BarraNavegacaoCustomizada extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BarraNavegacaoCustomizada({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.marfim,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.bordaSuave),
          boxShadow: [
            BoxShadow(
              color: AppColors.tinta.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(0, Icons.home_rounded, 'Início'),
            _item(1, Icons.calendar_today_rounded, 'Reservas'),
            _item(2, Icons.chat_bubble_rounded, 'Mensagens'),
            _item(3, Icons.person_rounded, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final bool ativo = i == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ativo ? AppColors.terracota : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 23,
              color: ativo ? Colors.white : AppColors.bege,
            ),
          ),
          const SizedBox(height: 3),
          // Espaço do rótulo é sempre reservado (altura fixa); só a opacidade
          // anima. Assim a barra nunca muda de tamanho ao trocar de aba.
          SizedBox(
            height: 13,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: ativo ? 1.0 : 0.0,
              child: Text(
                label,
                maxLines: 1,
                style: AppTypography.sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.terracota,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
