import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/widgets/card_refeicao.dart';
import 'filtro_chip.dart';
import 'modal_gerenciar_participantes.dart';

class ListaOrganizacao extends StatefulWidget {
  final Future<List<Cardapio>> jantaresFuture;
  final VoidCallback onRecarregar;

  const ListaOrganizacao({
    super.key,
    required this.jantaresFuture,
    required this.onRecarregar,
  });

  @override
  State<ListaOrganizacao> createState() => _ListaOrganizacaoState();
}

class _ListaOrganizacaoState extends State<ListaOrganizacao> {
  int _filtro = 0;

  void _abrirGerenciamento(BuildContext context, Cardapio jantar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalGerenciarParticipantes(
        jantar: jantar,
        onAtualizar: widget.onRecarregar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FiltroChip(
                label: 'Próximos',
                value: 0,
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
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: widget.jantaresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Você ainda não organizou jantares.'),
                );
              }

              final todos = snapshot.data!;
              final filtrados = todos.where((jantar) {
                final agora = DateTime.now();
                if (_filtro == 2) {
                  return jantar.hrEncontro.isBefore(agora);
                } else {
                  return jantar.hrEncontro.isAfter(agora);
                }
              }).toList();

              if (filtrados.isEmpty) {
                return const Center(child: Text("Nenhum jantar encontrado."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final jantar = filtrados[index];
                  final bool temPendencias = jantar.nuSolicitacoesPendentes > 0;

                  return Column(
                    children: [
                      CardRefeicao(
                        refeicao: jantar,
                        onRecarregar: widget.onRecarregar,
                      ),
                      if (_filtro == 0)
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextButton.icon(
                              onPressed: () =>
                                  _abrirGerenciamento(context, jantar),
                              icon: Icon(
                                Icons.people,
                                color: temPendencias
                                    ? Colors.red
                                    : Colors.black87,
                              ),
                              label: Text(
                                temPendencias
                                    ? "GERENCIAR (${jantar.nuSolicitacoesPendentes} NOVOS PEDIDOS)"
                                    : "VER LISTA DE CONVIDADOS",
                                style: TextStyle(
                                  color: temPendencias
                                      ? Colors.red
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
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
