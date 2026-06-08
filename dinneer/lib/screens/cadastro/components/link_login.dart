import 'package:flutter/material.dart';

/// Rodapé "Já tem login? Entre" usado nas etapas do cadastro.
/// Ao tocar em "Entre", volta para a tela anterior (login).
class LinkLogin extends StatelessWidget {
  const LinkLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Já tem login? ', style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            'Entre',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
