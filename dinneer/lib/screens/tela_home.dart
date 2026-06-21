import 'dart:async';

import 'package:dinneer/service/refeicao/cardapioService.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/refeicao/Cardapio.dart';
import '../service/sessao/SessionService.dart';
import '../widgets/card_refeicao.dart';
import '../widgets/card_destaque.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class TelaHome extends StatefulWidget {
  final int idUsuarioLogado;
  final void Function(int)? aoTrocarAba;

  const TelaHome({super.key, this.idUsuarioLogado = 0, this.aoTrocarAba});

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
  String? _primeiroNome;
  String? _fotoUsuario;

  @override
  void initState() {
    super.initState();
    _refeicoesFuture = _carregarRefeicoes();
    _categoriasFuture = _carregarCategorias();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await SessionService.getUsuario();
    if (!mounted) return;
    final nome = usuario['nm_usuario']?.toString();
    final foto = usuario['vl_foto']?.toString();
    setState(() {
      _primeiroNome =
          (nome != null && nome.isNotEmpty) ? nome.split(' ').first : null;
      _fotoUsuario =
          (foto != null && foto.isNotEmpty && foto != 'null') ? foto : null;
    });
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
              return item['categoria']?.toString() ?? '';
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
      backgroundColor: AppColors.creme,
      body: RefreshIndicator(
        onRefresh: _atualizarLista,
        color: AppColors.terracota,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagina,
                48,
                AppSpacing.pagina,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cabecalho(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFilterButtons(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Cardapio>>(
                future: _refeicoesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro: ${snapshot.error}",
                        style: AppTypography.sans(color: AppColors.bege),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Text(
                              "Nenhum jantar disponível no momento.",
                              style: AppTypography.sans(color: AppColors.bege),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final refeicoes = snapshot.data!;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagina,
                        AppSpacing.xs,
                        AppSpacing.pagina,
                        AppSpacing.lg,
                      ),
                      children: [
                        _tituloSecao('Destaques de hoje'),
                        const SizedBox(height: AppSpacing.md),
                        CardDestaque(
                          refeicao: refeicoes.first,
                          onRecarregar: _atualizarLista,
                        ),
                        if (refeicoes.length > 1) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _tituloSecao('Próximas jantadas'),
                          const SizedBox(height: AppSpacing.md),
                          ...refeicoes.skip(1).map(
                                (r) => CardRefeicao(
                                  refeicao: r,
                                  onRecarregar: _atualizarLista,
                                ),
                              ),
                        ],
                      ],
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

  Widget _cabecalho() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OLÁ,',
                style: AppTypography.sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bege,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                _primeiroNome ?? 'Bem-vindo',
                style: AppTypography.serif(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => widget.aoTrocarAba?.call(2),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.marfim,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.terracota,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => widget.aoTrocarAba?.call(3),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.tan,
            backgroundImage: _fotoUsuario != null
                ? CachedNetworkImageProvider(_fotoUsuario!)
                : null,
            child: _fotoUsuario == null
                ? const Icon(Icons.person, color: AppColors.tanTexto)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _tituloSecao(String titulo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(titulo, style: AppTypography.serif(fontSize: 18)),
        Text(
          'Ver todos',
          style: AppTypography.sans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.terracota,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _buscaController,
      onChanged: _alterarBusca,
      style: AppTypography.sans(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar por prato, chef, cidade...',
        prefixIcon: const Icon(Icons.search, color: AppColors.terracota),
        suffixIcon: _buscaController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: AppColors.bege),
                onPressed: _limparBusca,
              ),
        filled: true,
        fillColor: AppColors.marfim,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.bordaSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.bordaSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.terracota, width: 1.5),
        ),
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
        style: AppTypography.sans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.tanTexto,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.terracota,
      backgroundColor: AppColors.marfim,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isSelected ? AppColors.terracota : AppColors.bordaSuave,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    );
  }
}
