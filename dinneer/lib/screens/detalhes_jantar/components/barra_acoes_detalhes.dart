import 'package:flutter/material.dart';

import 'package:dinneer/service/refeicao/Cardapio.dart';

class BarraAcoesDetalhes extends StatelessWidget {
  final Cardapio refeicao;
  final bool souOAnfitriao;
  final bool estaLotado;
  final bool jaReservei;
  final String? statusReserva;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onCancelarReserva;
  final VoidCallback onSolicitarReserva;
  final VoidCallback onAvaliar;

  const BarraAcoesDetalhes({
    super.key,
    required this.refeicao,
    required this.souOAnfitriao,
    required this.estaLotado,
    required this.jaReservei,
    required this.statusReserva,
    required this.onEditar,
    required this.onExcluir,
    required this.onCancelarReserva,
    required this.onSolicitarReserva,
    required this.onAvaliar,
  });

  @override
  Widget build(BuildContext context) {
    return souOAnfitriao ? _botoesAnfitriao() : _botaoConvidado();
  }

  Widget _botoesAnfitriao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onEditar,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.black),
            ),
            child: const Text(
              "EDITAR",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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

  Widget _botaoConvidado() {
    final bool jantarJaPassou = refeicao.hrEncontro.isBefore(DateTime.now());

    if (jaReservei) {
      if (jantarJaPassou) {
        return ElevatedButton(
          onPressed: onAvaliar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "AVALIAR EXPERIÊNCIA",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      }

      if (statusReserva == 'P') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [
              Icon(Icons.access_time, color: Colors.orange, size: 30),
              SizedBox(height: 8),
              Text(
                "Solicitação Pendente",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                "Aguarde o anfitrião aceitar.",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }

      return ElevatedButton(
        onPressed: onCancelarReserva,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red),
          ),
          elevation: 0,
        ),
        child: const Text(
          "CANCELAR RESERVA",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    if (jantarJaPassou) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "JANTAR ENCERRADO",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    return ElevatedButton(
      onPressed: estaLotado ? null : onSolicitarReserva,
      style: ElevatedButton.styleFrom(
        backgroundColor: estaLotado ? Colors.grey : Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        estaLotado ? 'JANTAR LOTADO' : 'SOLICITAR RESERVA',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
