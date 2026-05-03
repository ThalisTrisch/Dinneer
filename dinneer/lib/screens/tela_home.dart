import 'package:dinneer/service/refeicao/cardapioService.dart';
import 'package:flutter/material.dart';
import '../service/refeicao/Cardapio.dart';
import '../widgets/card_refeicao.dart';

class TelaHome extends StatefulWidget {
  final int idUsuarioLogado;

  const TelaHome({super.key, this.idUsuarioLogado = 0});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  late Future<List<Cardapio>> _refeicoesFuture;

  @override
  void initState() {
    super.initState();
    _refeicoesFuture = _carregarRefeicoes();
  }

  Future<List<Cardapio>> _carregarRefeicoes() async {
    try {
      final resposta = await CardapioService.getCardapiosDisponiveis();
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Erro ao carregar refeições: $e");
      return [];
    }
  }

  Future<void> _atualizarLista() async {
    setState(() {
      _refeicoesFuture = _carregarRefeicoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: RefreshIndicator(
        onRefresh: _atualizarLista,
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildFilterButtons(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Cardapio>>(
                future: _refeicoesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erro: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: const Center(
                            child: Text("Nenhum jantar disponível no momento."),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final refeicoes = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: refeicoes.length,
                      itemBuilder: (context, index) {
                        final refeicao = refeicoes[index];
                        return CardRefeicao(
                          refeicao: refeicao,
                          onRecarregar: _atualizarLista, // <--- O PULO DO GATO
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por prato, cidade...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        _buildFilterChip('Data'),
        const SizedBox(width: 8),
        _buildFilterChip('Preço'),
        const SizedBox(width: 8),
        _buildFilterChip('Tipo'),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.black54)),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
