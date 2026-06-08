import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/screens/reservas/components/filtro_chip.dart';
import 'package:dinneer/screens/reservas/components/modal_gerenciar_participantes.dart';
import '../widgets/card_refeicao.dart';

class TelaReservas extends StatefulWidget {
  const TelaReservas({super.key});

  @override
  State<TelaReservas> createState() => _TelaReservasState();
}

class _TelaReservasState extends State<TelaReservas> {
  int _filtroParticipacao = 0;
  int _filtroOrganizacao = 0;

  late Future<List<Cardapio>> _minhasReservasFuture;
  late Future<List<Cardapio>> _meusJantaresCriadosFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _minhasReservasFuture = _buscarReservas();
      _meusJantaresCriadosFuture = _buscarJantaresCriados();
    });
  }

  Future<List<Cardapio>> _buscarReservas() async {
    try {
      final idStr = await SessionService.pegarUsuarioId();
      if (idStr == null) return [];

      final resposta = await EncontroService.getMinhasReservas(
        int.parse(idStr),
      );
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Cardapio>> _buscarJantaresCriados() async {
    try {
      final idStr = await SessionService.pegarUsuarioId();
      if (idStr == null) return [];

      final resposta = await EncontroService.getMeusJantaresCriados(
        int.parse(idStr),
      );
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void _abrirGerenciamento(BuildContext context, Cardapio jantar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalGerenciarParticipantes(
        jantar: jantar,
        onAtualizar: _carregarDados,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Minhas Reservas',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Participei'),
              Tab(text: 'Organizei'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildListaParticipacao(), _buildListaOrganizacao()],
        ),
      ),
    );
  }

  Widget _buildListaParticipacao() {
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
                  groupValue: _filtroParticipacao,
                  onTap: (v) => setState(() => _filtroParticipacao = v),
                ),
                const SizedBox(width: 10),
                FiltroChip(
                  label: 'Confirmados',
                  value: 1,
                  groupValue: _filtroParticipacao,
                  onTap: (v) => setState(() => _filtroParticipacao = v),
                ),
                const SizedBox(width: 10),
                FiltroChip(
                  label: 'Histórico',
                  value: 2,
                  groupValue: _filtroParticipacao,
                  onTap: (v) => setState(() => _filtroParticipacao = v),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: _minhasReservasFuture,
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

                if (_filtroParticipacao == 2) {
                  return ehPassado;
                } else if (_filtroParticipacao == 0) {
                  return ehFuturo && status == 'P';
                } else if (_filtroParticipacao == 1) {
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
                    onRecarregar: _carregarDados,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListaOrganizacao() {
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
                groupValue: _filtroOrganizacao,
                onTap: (v) => setState(() => _filtroOrganizacao = v),
              ),
              const SizedBox(width: 10),
              FiltroChip(
                label: 'Histórico',
                value: 2,
                groupValue: _filtroOrganizacao,
                onTap: (v) => setState(() => _filtroOrganizacao = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: _meusJantaresCriadosFuture,
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
                if (_filtroOrganizacao == 2) {
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
                        onRecarregar: _carregarDados,
                      ),

                      if (_filtroOrganizacao == 0)
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
