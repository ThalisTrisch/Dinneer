import 'dart:async';

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
  late Future<List<String>> _categoriasFuture;
  final TextEditingController _buscaController = TextEditingController();
  Timer? _buscaDebounce;
  String? _categoriaSelecionada;
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _refeicoesFuture = _carregarRefeicoes();
    _categoriasFuture = _carregarCategorias();
  }

  @override
  void dispose() {
    _buscaDebounce?.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  Future<List<Cardapio>> _carregarRefeicoes() async {
    try {
      final resposta = _categoriaSelecionada == null
          ? await CardapioService.getCardapiosDisponiveis()
          : await CardapioService.getCardapiosPorCategoria(
              _categoriaSelecionada!,
            );

      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        final refeicoes = dados.map((item) => Cardapio.fromMap(item)).toList();
        return _filtrarPorBusca(refeicoes);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Erro ao carregar refeições: $e");
      return [];
    }
  }

  Future<List<String>> _carregarCategorias() async {
    try {
      final resposta = await CardapioService.getCategorias();
      if (resposta['dados'] == null) return [];

      final dados = List<dynamic>.from(resposta['dados']);
      return dados
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['nm_categoria']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((categoria) => categoria.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint("Erro ao carregar categorias: $e");
      return [];
    }
  }

  Future<void> _atualizarLista() async {
    setState(() {
      _refeicoesFuture = _carregarRefeicoes();
    });
  }

  void _selecionarCategoria(String? categoria) {
    setState(() {
      _categoriaSelecionada = categoria;
      _refeicoesFuture = _carregarRefeicoes();
    });
  }

  void _alterarBusca(String texto) {
    _buscaDebounce?.cancel();
    _buscaDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        _termoBusca = texto.trim();
        _refeicoesFuture = _carregarRefeicoes();
      });
    });
  }

  void _limparBusca() {
    _buscaDebounce?.cancel();
    _buscaController.clear();
    setState(() {
      _termoBusca = '';
      _refeicoesFuture = _carregarRefeicoes();
    });
  }

  List<Cardapio> _filtrarPorBusca(List<Cardapio> refeicoes) {
    final termo = _termoBusca.toLowerCase();
    if (termo.isEmpty) return refeicoes;

    return refeicoes.where((refeicao) {
      final camposBusca = [
        refeicao.nmCardapio,
        refeicao.dsCardapio,
        refeicao.nmUsuarioAnfitriao,
        refeicao.nuCep,
        refeicao.nuCasa,
        refeicao.precoFormatado,
      ].join(' ').toLowerCase();

      return camposBusca.contains(termo);
    }).toList();
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
                          onRecarregar: _atualizarLista,
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
      controller: _buscaController,
      onChanged: _alterarBusca,
      decoration: InputDecoration(
        hintText: 'Buscar por prato, cidade...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        suffixIcon: _buscaController.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: Colors.grey[500]),
                onPressed: _limparBusca,
              ),
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
    return FutureBuilder<List<String>>(
      future: _categoriasFuture,
      builder: (context, snapshot) {
        final categorias = snapshot.data ?? [];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'Todos',
                isSelected: _categoriaSelecionada == null,
                onSelected: () => _selecionarCategoria(null),
              ),
              for (final categoria in categorias) ...[
                const SizedBox(width: 8),
                _buildFilterChip(
                  categoria,
                  isSelected: _categoriaSelecionada == categoria,
                  onSelected: () => _selecionarCategoria(categoria),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label, {
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black54),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.black,
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
