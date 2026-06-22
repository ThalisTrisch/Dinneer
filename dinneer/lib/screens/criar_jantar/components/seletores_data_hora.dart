import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeletoresDataHora extends StatelessWidget {
  final DateTime? data;
  final TimeOfDay? hora;
  final VoidCallback onSelecionarData;
  final VoidCallback onSelecionarHora;

  const SeletoresDataHora({
    super.key,
    required this.data,
    required this.hora,
    required this.onSelecionarData,
    required this.onSelecionarHora,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSelecionarData,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              data == null ? "Data" : DateFormat('dd/MM').format(data!),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSelecionarHora,
            icon: const Icon(Icons.access_time),
            label: Text(hora == null ? "Hora" : hora!.format(context)),
          ),
        ),
      ],
    );
  }
}
