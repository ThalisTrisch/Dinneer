import 'package:flutter/material.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class ItemParticipante extends StatelessWidget {
  final Map<String, dynamic> participante;
  final VoidCallback onAbrirPerfil;
  final VoidCallback onAprovar;
  final VoidCallback onRejeitar;

  const ItemParticipante({
    super.key,
    required this.participante,
    required this.onAbrirPerfil,
    required this.onAprovar,
    required this.onRejeitar,
  });

  @override
  Widget build(BuildContext context) {
    final bool pendente = participante['fl_status'] == 'P';
    final String nome = participante['nome_completo'];
    final String? foto = participante['vl_foto'];
    final temFoto = foto != null && foto != "";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: pendente
          ? Colors.orange.withValues(alpha: 0.1)
          : AppColors.marfim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: pendente
              ? Colors.orange.withValues(alpha: 0.3)
              : AppColors.bordaSuave,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onAbrirPerfil,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: temFoto ? NetworkImage(foto) : null,
                child: !temFoto ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: AppTypography.serif(fontSize: 16),
                    ),
                    Text(
                      pendente
                          ? "Solicitação de +${participante['nu_dependentes']}"
                          : "Confirmado +${participante['nu_dependentes']}",
                      style: TextStyle(
                        color: pendente
                            ? Colors.orange[800]
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (pendente) ...[
                IconButton(
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  onPressed: onAprovar,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                  onPressed: onRejeitar,
                ),
              ] else ...[
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
