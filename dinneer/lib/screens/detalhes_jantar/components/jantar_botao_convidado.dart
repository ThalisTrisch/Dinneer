import 'package:flutter/material.dart';
import 'package:dinneer/widgets/modal_avaliacao.dart';

class JantarBotaoConvidado extends StatelessWidget {
  final bool jaReservei;
  final bool jantarJaPassou;
  final bool estaLotado;
  final String? statusReserva;
  final int? idUsuarioLogado;
  final int idEncontro;
  final VoidCallback onSolicitarReserva;
  final VoidCallback onCancelarReserva;

  const JantarBotaoConvidado({
    super.key,
    required this.jaReservei,
    required this.jantarJaPassou,
    required this.estaLotado,
    required this.statusReserva,
    required this.idUsuarioLogado,
    required this.idEncontro,
    required this.onSolicitarReserva,
    required this.onCancelarReserva,
  });

  @override
  Widget build(BuildContext context) {
    if (jaReservei) {
      if (jantarJaPassou) {
        return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => ModalAvaliacao(
                idUsuario: idUsuarioLogado!,
                idEncontro: idEncontro,
                onAvaliacaoConcluida: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Obrigado pela avaliação!")),
                  );
                },
              ),
            );
          },
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
          child: const Column(
            children: [
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
