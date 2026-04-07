import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/widgets/card_refeicao.dart';

class ListaJantaresOrganizados extends StatelessWidget {
  final List<Cardapio> jantares;

  const ListaJantaresOrganizados({super.key, required this.jantares});

  @override
  Widget build(BuildContext context) {
    if (jantares.isEmpty) {
      return const Center(child: Text("Nenhum jantar público encontrado."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jantares.length,
      itemBuilder: (ctx, index) {
        return CardRefeicao(refeicao: jantares[index]);
      },
    );
  }
}
