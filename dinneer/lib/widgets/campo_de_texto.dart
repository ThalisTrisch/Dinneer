import 'package:flutter/material.dart';

class CampoDeTextoCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String dica;
  final bool textoObscuro;

  const CampoDeTextoCustomizado({
    super.key,
    required this.controller,
    required this.dica,
    this.textoObscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: textoObscuro,
      decoration: InputDecoration(hintText: dica),
    );
  }
}
