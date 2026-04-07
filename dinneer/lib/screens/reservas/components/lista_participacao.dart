import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/widgets/card_refeicao.dart';
import 'filtro_chip.dart';

class ListaParticipacao extends StatefulWidget {
  final Future<List<Cardapio>> reservasFuture;
  final VoidCallback onRecarregar;

  const ListaParticipacao({
    super.key,
    required this.reservasFuture,
    required this.onRecarregar,
  });

  @override
  State<ListaParticipacao> createState() => _ListaParticipacaoState();
}

class _ListaParticipacaoState extends State<ListaParticipacao> {
  int _filtro = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FiltroChip(
                  label: 'Pendentes',
                  value: 0,
                  groupValue: _filtro,
                  onTap: (v) => setState(() => _filtro = v),
                ),
                const SizedBox(width: 10),
                FiltroChip(
                  label: 'Confirmados',
                  value: 1,
                  groupValue: _filtro,
                  onTap: (v) => setState(() => _filtro = v),
                ),
                const SizedBox(width: 10),
                FiltroChip(
                  label: 'Histórico',
                  value: 2,
                  groupValue: _filtro,
                  onTap: (v) => setState(() => _filtro = v),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: widget.reservasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma reserva encontrada.'));
              }

              final todos = snapshot.data!;
              final filtrados = todos.where((jantar) {
                final agora = DateTime.now();
                final bool ehPassado = jantar.hrEncontro.isBefore(agora);
                final bool ehFuturo = !ehPassado;
                final String status = jantar.statusReserva ?? 'P';

                if (_filtro == 2) {
                  return ehPassado;
                } else if (_filtro == 0) {
                  return ehFuturo && status == 'P';
                } else if (_filtro == 1) {
                  return ehFuturo && status == 'C';
                }

                return false;
              }).toList();

              if (filtrados.isEmpty) {
                return const Center(
                  child: Text("Nenhum item nesta categoria."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  return CardRefeicao(
                    refeicao: filtrados[index],
                    onRecarregar: widget.onRecarregar,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
