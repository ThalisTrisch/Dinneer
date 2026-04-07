import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/screens/jantar/tela_editar_jantar.dart';

class JantarBotoesAnfitriao extends StatelessWidget {
  final Cardapio jantar;
  final VoidCallback onExcluir;

  const JantarBotoesAnfitriao({
    super.key,
    required this.jantar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final atualizou = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaEditarJantar(jantar: jantar),
                ),
              );
              if (atualizou == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.black),
            ),
            child: const Text(
              "EDITAR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onExcluir,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "CANCELAR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
