import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import '../theme/app_colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.marfim,
        boxShadow: [
          BoxShadow(
            color: AppColors.tinta.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavyBar(
        selectedIndex: index,
        onItemSelected: onTap,
        backgroundColor: AppColors.marfim,
        itemCornerRadius: 12,
        curve: Curves.easeIn,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.home_rounded),
            title: const Text('Início'),
            activeColor: AppColors.terracota,
            inactiveColor: AppColors.bege,
            textAlign: TextAlign.center,
          ),

          BottomNavyBarItem(
            icon: const Icon(Icons.calendar_today_rounded),
            title: const Text('Reservas'),
            activeColor: AppColors.terracota,
            inactiveColor: AppColors.bege,
            textAlign: TextAlign.center,
          ),

          BottomNavyBarItem(
            icon: const Icon(Icons.chat_bubble_rounded),
            title: const Text('Mensagens'),
            activeColor: AppColors.terracota,
            inactiveColor: AppColors.bege,
            textAlign: TextAlign.center,
          ),

          BottomNavyBarItem(
            icon: const Icon(Icons.person_rounded),
            title: const Text('Perfil'),
            activeColor: AppColors.terracota,
            inactiveColor: AppColors.bege,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
