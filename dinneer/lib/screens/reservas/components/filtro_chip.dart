import 'package:flutter/material.dart';
import 'package:dinneer/theme/app_colors.dart';

class FiltroChip extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int> onTap;

  const FiltroChip({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracota : AppColors.marfim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.terracota : AppColors.bordaSuave,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.tanTexto,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
