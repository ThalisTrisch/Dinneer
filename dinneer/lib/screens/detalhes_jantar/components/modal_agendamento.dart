import 'package:flutter/material.dart';

/// Conteúdo do modal de agendamento: coleta o número de convidados extras
/// e dispara [onEnviar] com esse valor após fechar o modal.
class ModalAgendamento extends StatefulWidget {
  final void Function(int dependentes) onEnviar;

  const ModalAgendamento({super.key, required this.onEnviar});

  @override
  State<ModalAgendamento> createState() => _ModalAgendamentoState();
}

class _ModalAgendamentoState extends State<ModalAgendamento> {
  final TextEditingController _dependentesController = TextEditingController();

  @override
  void dispose() {
    _dependentesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agendamento",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Quantas pessoas irão jantar com você?"),
            const SizedBox(height: 8),
            TextField(
              controller: _dependentesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Número de convidados extras (0 se for só você)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final int dependentes =
                      int.tryParse(_dependentesController.text) ?? 0;
                  Navigator.pop(context);
                  widget.onEnviar(dependentes);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "ENVIAR SOLICITAÇÃO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
