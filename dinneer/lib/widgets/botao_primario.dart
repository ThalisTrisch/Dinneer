import 'package:flutter/material.dart';

/// Botão de ação principal padronizado do app.
///
/// Encapsula o ElevatedButton repetido em várias telas (fundo preto, texto
/// em maiúsculas, cantos arredondados) e o estado de carregamento: quando
/// [estaCarregando] é true, mostra um spinner e desabilita o toque.
///
/// Cores são parametrizáveis para cobrir as variações existentes sem mudar
/// o visual de cada tela.
class BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool estaCarregando;
  final Color corFundo;
  final Color corTexto;

  /// Largura total (double.infinity) quando true; caso contrário, usa o
  /// tamanho natural definido pelo contexto (ex.: dentro de um Expanded).
  final bool larguraTotal;

  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.estaCarregando = false,
    this.corFundo = Colors.black,
    this.corTexto = Colors.white,
    this.larguraTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    final botao = ElevatedButton(
      onPressed: estaCarregando ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: corFundo,
        foregroundColor: corTexto,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: estaCarregando
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: corTexto, strokeWidth: 2),
            )
          : Text(
              texto,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
    );

    if (!larguraTotal) return botao;
    return SizedBox(width: double.infinity, child: botao);
  }
}
