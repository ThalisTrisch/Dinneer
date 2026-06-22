import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dinneer/service/avaliacao/AvaliacaoService.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class TabAvaliacoes extends StatefulWidget {
  final int idUsuario;

  const TabAvaliacoes({super.key, required this.idUsuario});

  @override
  State<TabAvaliacoes> createState() => _TabAvaliacoesState();
}

class _TabAvaliacoesState extends State<TabAvaliacoes> {
  double mediaGeral = 0;
  int totalAvaliacoes = 0;
  List<Map<String, dynamic>> avaliacoesPorDia = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  Future<void> _carregarNotas() async {
    final dados = await AvaliacaoService.getMediaUsuario(widget.idUsuario);
    final detalhes = await AvaliacaoService.getAvaliacoesPorDia(
      widget.idUsuario,
    );

    if (mounted) {
      setState(() {
        mediaGeral = (dados['media'] as num).toDouble();
        totalAvaliacoes = dados['total'] as int;
        avaliacoesPorDia = detalhes;
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.terracotaSuave,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bordaSuave),
          ),
          child: Column(
            children: [
              Text(
                "Média Geral",
                style: AppTypography.serif(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                mediaGeral.toStringAsFixed(1),
                style: AppTypography.serif(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: AppColors.terracota,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < mediaGeral.round() ? Icons.star : Icons.star_border,
                    color: AppColors.terracota,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                "Baseado em $totalAvaliacoes avaliações",
                style: AppTypography.sans(color: AppColors.bege),
              ),
            ],
          ),
        ),

        Text(
          "Avaliações por dia",
          style: AppTypography.serif(fontSize: 18),
        ),
        const SizedBox(height: 10),
        _buildGraficoAvaliacoes(),
      ],
    );
  }

  Widget _buildGraficoAvaliacoes() {
    if (avaliacoesPorDia.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.marfim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordaSuave),
        ),
        child: Column(
          children: [
            const Icon(Icons.bar_chart_rounded, color: AppColors.tan, size: 42),
            const SizedBox(height: 8),
            Text(
              "Ainda não há avaliações por dia para exibir.",
              textAlign: TextAlign.center,
              style: AppTypography.sans(color: AppColors.bege),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.marfim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordaSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Media diaria",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "$totalAvaliacoes notas",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEixoNotas(),
                const SizedBox(width: 10),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (_) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: avaliacoesPorDia.asMap().entries.map((
                            entry,
                          ) {
                            final isUltima =
                                entry.key == avaliacoesPorDia.length - 1;
                            return _BarraAvaliacaoDia(
                              dados: entry.value,
                              destaque: isUltima,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEixoNotas() {
    return SizedBox(
      width: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final nota = 5 - index;
          return Text(
            nota.toString(),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          );
        }),
      ),
    );
  }
}

class _BarraAvaliacaoDia extends StatelessWidget {
  final Map<String, dynamic> dados;
  final bool destaque;

  const _BarraAvaliacaoDia({required this.dados, required this.destaque});

  @override
  Widget build(BuildContext context) {
    final media = ((dados['media'] as num).toDouble().clamp(
      0.0,
      5.0,
    )).toDouble();
    final total = dados['total'] as int;
    final altura = (media / 5) * 160;
    final data = DateTime.tryParse(dados['data'].toString());
    final labelData = data == null
        ? dados['data'].toString()
        : DateFormat('dd/MM', 'pt_BR').format(data);
    final corBarra = destaque ? AppColors.terracota : AppColors.tanTexto;
    final tooltip = _buildTooltip(labelData, media, total);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              media.toStringAsFixed(1),
              style: TextStyle(
                color: destaque ? AppColors.terracota : AppColors.tinta,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42,
              height: altura < 8 ? 8 : altura,
              decoration: BoxDecoration(
                color: corBarra,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              labelData,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: destaque ? AppColors.terracota : AppColors.bege,
                fontSize: 12,
                fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$total notas",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTooltip(String labelData, double media, int total) {
    final encontros = dados['encontros'] is List
        ? dados['encontros'] as List
        : const [];

    final linhas = [
      "$labelData - media do dia ${media.toStringAsFixed(1)} ($total notas)",
      if (encontros.isNotEmpty) "",
      ...encontros.map((encontro) {
        final id = encontro['id_encontro'];
        final nota = ((encontro['media'] as num?)?.toDouble() ?? 0)
            .toStringAsFixed(1);
        final totalEncontro = encontro['total'] ?? 0;
        return "Encontro #$id: nota $nota ($totalEncontro notas)";
      }),
    ];

    return linhas.join('\n');
  }
}
