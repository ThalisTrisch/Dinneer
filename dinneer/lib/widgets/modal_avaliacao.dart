import 'package:flutter/material.dart';
import 'package:dinneer/service/avaliacao/AvaliacaoService.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class ModalAvaliacao extends StatefulWidget {
  final int idUsuario;
  final int idEncontro;
  final VoidCallback onAvaliacaoConcluida;

  const ModalAvaliacao({
    super.key,
    required this.idUsuario,
    required this.idEncontro,
    required this.onAvaliacaoConcluida,
  });

  @override
  State<ModalAvaliacao> createState() => _ModalAvaliacaoState();
}

class _ModalAvaliacaoState extends State<ModalAvaliacao> {
  double _notaComida = 0;
  double _notaHospitalidade = 0;
  double _notaPontualidade = 0;
  bool _enviando = false;

  Future<void> _enviarAvaliacoes() async {
    if (_notaComida == 0 || _notaHospitalidade == 0 || _notaPontualidade == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, avalie todos os itens.")),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      await AvaliacaoService.avaliar(
        widget.idUsuario,
        widget.idEncontro,
        1,
        _notaComida,
      );
      await AvaliacaoService.avaliar(
        widget.idUsuario,
        widget.idEncontro,
        2,
        _notaHospitalidade,
      );
      await AvaliacaoService.avaliar(
        widget.idUsuario,
        widget.idEncontro,
        3,
        _notaPontualidade,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onAvaliacaoConcluida();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avaliação enviada com sucesso! ⭐"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        final jaAvaliou = msg.toLowerCase().contains('já avaliou');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jaAvaliou ? "Você já avaliou este jantar." : "Erro ao avaliar. Tente novamente.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        if (jaAvaliou) {
          Navigator.pop(context);
        } else {
          setState(() => _enviando = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.creme,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Avaliar Jantar",
            style: AppTypography.serif(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          _buildStarRow(
            "Comida",
            _notaComida,
            (v) => setState(() => _notaComida = v),
          ),
          const SizedBox(height: 16),
          _buildStarRow(
            "Hospitalidade",
            _notaHospitalidade,
            (v) => setState(() => _notaHospitalidade = v),
          ),
          const SizedBox(height: 16),
          _buildStarRow(
            "Pontualidade",
            _notaPontualidade,
            (v) => setState(() => _notaPontualidade = v),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _enviando ? null : _enviarAvaliacoes,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracota,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text(
                    "ENVIAR AVALIAÇÃO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(
    String label,
    double notaAtual,
    Function(double) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onChanged(index + 1.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < notaAtual
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
