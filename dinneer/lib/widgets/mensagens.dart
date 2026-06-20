import 'package:flutter/material.dart';

class Mensagens {
  Mensagens._();

  static void erro(BuildContext context, String texto) =>
      _mostrar(context, texto, fundo: Colors.red);

  static void sucesso(BuildContext context, String texto) =>
      _mostrar(context, texto, fundo: Colors.green);

  static void aviso(BuildContext context, String texto) =>
      _mostrar(context, texto, fundo: Colors.orange);

  static void neutra(BuildContext context, String texto) =>
      _mostrar(context, texto);

  static void _mostrar(BuildContext context, String texto, {Color? fundo}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto), backgroundColor: fundo));
  }
}
