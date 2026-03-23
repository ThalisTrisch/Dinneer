import 'package:flutter/material.dart';
import 'package:dinneer/service/http/HttpService.dart';
import 'package:dinneer/service/avaliacao/AvaliacaoService.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/widgets/card_refeicao.dart';

class TelaPerfilPublico extends StatefulWidget {
  final int idUsuario;
  final String nomeUsuario; 
  final String? fotoUrl;

  const TelaPerfilPublico({
    super.key,
    required this.idUsuario,
    required this.nomeUsuario,
    this.fotoUrl,
  });

  @override
  State<TelaPerfilPublico> createState() => _TelaPerfilPublicoState();
}

class _TelaPerfilPublicoState extends State<TelaPerfilPublico> with SingleTickerProviderStateMixin {
  final HttpService http = HttpService();
  late TabController _tabController;

  Map<String, dynamic>? dadosUsuario;
  double media = 0;
  int totalAvaliacoes = 0;
  List<Cardapio> jantaresOrganizados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); 
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() => carregando = true);
    await Future.wait([
      _carregarDadosUsuario(),
      _carregarReputacao(),
      _carregarJantares(),
    ]);
    if (mounted) setState(() => carregando = false);
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final res = await http.get("usuario/UsuarioController.php", "getUsuario", queryParams: {
        "id_usuario": widget.idUsuario.toString()
      });
      if (res['dados'] != null && (res['dados'] as List).isNotEmpty) {
        dadosUsuario = (res['dados'] as List).first;
      }
    } catch (e) {
      debugPrint("Erro user: $e");
    }
  }

  Future<void> _carregarReputacao() async {
    try {
      final dados = await AvaliacaoService.getMediaUsuario(widget.idUsuario);
      media = dados['media'];
      totalAvaliacoes = dados['total'];
    } catch (e) {
      debugPrint("Erro reputacao: $e");
    }
  }

  Future<void> _carregarJantares() async {
    try {
      final res = await EncontroService.getMeusJantaresCriados(widget.idUsuario);
      if (res['dados'] != null) {
        final lista = List<dynamic>.from(res['dados']);
        jantaresOrganizados = lista.map((e) => Cardapio.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint("Erro jantares: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String nomeExibicao = dadosUsuario?['nm_usuario'] ?? widget.nomeUsuario;
    String sobrenome = dadosUsuario?['nm_sobrenome'] ?? "";
    String foto = dadosUsuario?['vl_foto'] ?? widget.fotoUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: (foto.isNotEmpty && foto != 'null') 
                                  ? NetworkImage(foto) 
                                  : null,
                              child: (foto.isEmpty || foto == 'null') 
                                  ? const Icon(Icons.person, size: 50) 
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "$nomeExibicao $sobrenome",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                const SizedBox(width: 4),
                                Text(
                                  media.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  " ($totalAvaliacoes avaliações)",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.black,
                        tabs: const [
                          Tab(text: "Jantares Organizados"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  jantaresOrganizados.isEmpty
                      ? const Center(child: Text("Nenhum jantar público encontrado."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: jantaresOrganizados.length,
                          itemBuilder: (ctx, index) {
                            return CardRefeicao(refeicao: jantaresOrganizados[index]);
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}