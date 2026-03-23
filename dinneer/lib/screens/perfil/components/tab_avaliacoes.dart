import 'package:flutter/material.dart';
import 'package:dinneer/service/avaliacao/AvaliacaoService.dart';

class TabAvaliacoes extends StatefulWidget {
  final int idUsuario;

  const TabAvaliacoes({super.key, required this.idUsuario});

  @override
  State<TabAvaliacoes> createState() => _TabAvaliacoesState();
}

class _TabAvaliacoesState extends State<TabAvaliacoes> {
  double mediaGeral = 0;
  int totalAvaliacoes = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    print("--- TAB AVALIACOES: Iniciada para User ${widget.idUsuario} ---");
    _carregarNotas();
  }

  Future<void> _carregarNotas() async {
    final dados = await AvaliacaoService.getMediaUsuario(widget.idUsuario);
    if (mounted) {
      setState(() {
        mediaGeral = dados['media'];
        totalAvaliacoes = dados['total'];
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text("Média Geral", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                mediaGeral.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < mediaGeral.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text("Baseado em $totalAvaliacoes avaliações", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        const Text("Detalhes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        _buildRatingCard('Comida', mediaGeral),
        _buildRatingCard('Hospitalidade', mediaGeral),
        _buildRatingCard('Pontualidade', mediaGeral),
      ],
    );
  }

  Widget _buildRatingCard(String category, double rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}