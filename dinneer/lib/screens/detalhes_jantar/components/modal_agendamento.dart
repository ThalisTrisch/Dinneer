import 'package:flutter/material.dart';

class ModalAgendamento extends StatelessWidget {
  final Function(int) onConfirmar;

  const ModalAgendamento({super.key, required this.onConfirmar});

  @override
  Widget build(BuildContext context) {
    final TextEditingController dependentesController = TextEditingController();

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
              controller: dependentesController,
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
                      int.tryParse(dependentesController.text) ?? 0;
                  Navigator.pop(context);
                  onConfirmar(dependentes);
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
