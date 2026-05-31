import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Linha "A X de você" mostrando a distância até o jantar.
///
/// Quando [distanciaKm] é nulo (localização indisponível ou ainda
/// carregando), não renderiza nada — a tela segue normal, só sem a distância.
class DistanciaUsuario extends StatelessWidget {
  final double? distanciaKm;

  const DistanciaUsuario({super.key, required this.distanciaKm});

  /// Formata a distância de forma amigável em pt-BR:
  /// abaixo de 1 km mostra metros arredondados; acima, km com 1 casa.
  static String formatar(double km) {
    if (km < 1) {
      final metros = (km * 1000).round();
      return "A $metros m de você";
    }
    final texto = NumberFormat("#,##0.0", "pt_BR").format(km);
    return "A $texto km de você";
  }

  @override
  Widget build(BuildContext context) {
    if (distanciaKm == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            formatar(distanciaKm!),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
