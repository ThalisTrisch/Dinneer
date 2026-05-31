import 'package:flutter/material.dart';

/// Helper para exibir SnackBars padronizados, evitando repetir
/// `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` em toda tela.
///
/// Cobre apenas os casos simples (texto + cor de fundo). SnackBars com
/// conteúdo customizado (ex.: spinner de "enviando...") continuam montados
/// manualmente onde precisam.
class Mensagens {
  Mensagens._();

  /// Mensagem de erro (fundo vermelho).
  static void erro(BuildContext context, String texto) =>
      _mostrar(context, texto, fundo: Colors.red);

  /// Mensagem de sucesso (fundo verde).
  static void sucesso(BuildContext context, String texto) =>
      _mostrar(context, texto, fundo: Colors.green);

  /// Mensagem de atenção (fundo laranja).
  static void aviso(BuildContext context, String texto) =>
      _mostrar(context, texto, fundo: Colors.orange);

  /// Mensagem neutra (sem cor de fundo, usa o padrão do tema).
  static void neutra(BuildContext context, String texto) =>
      _mostrar(context, texto);

  static void _mostrar(BuildContext context, String texto, {Color? fundo}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto), backgroundColor: fundo));
  }
}
