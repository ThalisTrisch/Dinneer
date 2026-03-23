import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/service/http/HttpService.dart';
import 'package:dinneer/screens/tela_perfil_publico.dart';
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
      
      final resposta = await EncontroService.getMinhasReservas(int.parse(idStr));
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

      final resposta = await EncontroService.getMeusJantaresCriados(int.parse(idStr));
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
      builder: (_) => _ModalGerenciarParticipantes(
        jantar: jantar, 
        onAtualizar: _carregarDados
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)
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
          children: [
            _buildListaParticipacao(),
            _buildListaOrganizacao(),
          ],
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
                _buildFilterChip('Pendentes', 0, _filtroParticipacao, (v) => setState(() => _filtroParticipacao = v)),
                const SizedBox(width: 10),
                _buildFilterChip('Confirmados', 1, _filtroParticipacao, (v) => setState(() => _filtroParticipacao = v)),
                const SizedBox(width: 10),
                _buildFilterChip('Histórico', 2, _filtroParticipacao, (v) => setState(() => _filtroParticipacao = v)),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: _minhasReservasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
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
                } 
                else if (_filtroParticipacao == 0) {
                   return ehFuturo && status == 'P';
                } 
                else if (_filtroParticipacao == 1) {
                   return ehFuturo && status == 'C';
                }
                
                return false;
              }).toList();

              if (filtrados.isEmpty) return const Center(child: Text("Nenhum item nesta categoria."));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  return CardRefeicao(refeicao: filtrados[index], onRecarregar: _carregarDados);
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
              _buildFilterChip('Próximos', 0, _filtroOrganizacao, (v) => setState(() => _filtroOrganizacao = v)),
              const SizedBox(width: 10),
              _buildFilterChip('Histórico', 2, _filtroOrganizacao, (v) => setState(() => _filtroOrganizacao = v)),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: _meusJantaresCriadosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Você ainda não organizou jantares.'));
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

              if (filtrados.isEmpty) return const Center(child: Text("Nenhum jantar encontrado."));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final jantar = filtrados[index];
                  final bool temPendencias = jantar.nuSolicitacoesPendentes > 0;

                  return Column(
                    children: [
                      CardRefeicao(refeicao: jantar, onRecarregar: _carregarDados),
                      
                      if (_filtroOrganizacao == 0)
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextButton.icon(
                              onPressed: () => _abrirGerenciamento(context, jantar),
                              icon: Icon(
                                Icons.people, 
                                color: temPendencias ? Colors.red : Colors.black87
                              ),
                              label: Text(
                                temPendencias 
                                  ? "GERENCIAR (${jantar.nuSolicitacoesPendentes} NOVOS PEDIDOS)" 
                                  : "VER LISTA DE CONVIDADOS",
                                style: TextStyle(
                                  color: temPendencias ? Colors.red : Colors.black87, 
                                  fontWeight: FontWeight.bold
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

  Widget _buildFilterChip(String label, int value, int groupValue, Function(int) onTap) {
    final bool isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54, 
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }
}

class _ModalGerenciarParticipantes extends StatefulWidget {
  final Cardapio jantar;
  final VoidCallback onAtualizar;

  const _ModalGerenciarParticipantes({required this.jantar, required this.onAtualizar});

  @override
  State<_ModalGerenciarParticipantes> createState() => _ModalGerenciarParticipantesState();
}

class _ModalGerenciarParticipantesState extends State<_ModalGerenciarParticipantes> {
  final HttpService http = HttpService();
  List<dynamic> participantes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarParticipantes();
  }

  Future<void> _carregarParticipantes() async {
    try {
      final res = await http.get("encontro/EncontroController.php", "getParticipantes", queryParams: {
        "id_encontro": widget.jantar.idEncontro.toString(),
      });
      if (mounted) {
        setState(() {
          participantes = res['dados'] ?? [];
          carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _alterarStatus(int idConvidado, bool aprovar) async {
    final operacao = aprovar ? "aprovarReserva" : "rejeitarReserva";
    setState(() => carregando = true);
    
    try {
      await http.post("encontro/EncontroController.php", operacao, body: {
        "id_encontro": widget.jantar.idEncontro.toString(),
        "id_convidado": idConvidado.toString(),
      });
      
      await _carregarParticipantes(); 
      widget.onAtualizar(); 
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gerenciar Convidados", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(widget.jantar.nmCardapio, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: const Icon(Icons.close, color: Colors.grey)
              ),
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: carregando 
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : participantes.isEmpty 
                  ? const Center(child: Text("Lista de convidados vazia.")) 
                  : ListView.builder(
                      itemCount: participantes.length,
                      itemBuilder: (context, index) {
                        final p = participantes[index];
                        final bool pendente = p['fl_status'] == 'P';
                        final int idUsuario = int.parse(p['id_usuario'].toString());
                        final String nome = p['nome_completo'];
                        final String? foto = p['vl_foto'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: pendente ? Colors.orange.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: pendente ? Colors.orange.withOpacity(0.3) : Colors.transparent)
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TelaPerfilPublico(
                                    idUsuario: idUsuario,
                                    nomeUsuario: nome,
                                    fotoUrl: foto,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: (foto != null && foto != "") ? NetworkImage(foto) : null,
                                    child: (foto == null || foto == "") ? const Icon(Icons.person) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(
                                          pendente ? "Solicitação de +${p['nu_dependentes']}" : "Confirmado +${p['nu_dependentes']}",
                                          style: TextStyle(
                                            color: pendente ? Colors.orange[800] : Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (pendente) ...[
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                                      onPressed: () => _alterarStatus(idUsuario, true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                                      onPressed: () => _alterarStatus(idUsuario, false),
                                    ),
                                  ] else ...[
                                    const Icon(Icons.check, color: Colors.green),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          )
        ],
      ),
    );
  }
}