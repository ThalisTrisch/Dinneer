import 'package:flutter/material.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';
import 'tela_chat.dart';

class TelaListaChats extends StatefulWidget {
  const TelaListaChats({super.key});

  @override
  State<TelaListaChats> createState() => _TelaListaChatsState();
}

class _TelaListaChatsState extends State<TelaListaChats> {
  List<dynamic> _encontros = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _carregarEncontros();
  }

  Future<void> _carregarEncontros() async {
    setState(() => _isLoading = true);

    try {
      final userData = await SessionService.getUsuario();
      _userId = userData['id_usuario']?.toString();

      if (_userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final reservas = await EncontroService.getMinhasReservas(
        int.parse(_userId!),
      );

      final jantares = await EncontroService.getMeusJantaresCriados(
        int.parse(_userId!),
      );

      final List<dynamic> todosEncontros = [];

      if (reservas['dados'] != null) {
        final reservasList = reservas['dados'] is List
            ? reservas['dados']
            : [reservas['dados']];
        todosEncontros.addAll(reservasList);
      }

      if (jantares['dados'] != null) {
        final jantaresList = jantares['dados'] is List
            ? jantares['dados']
            : [jantares['dados']];
        todosEncontros.addAll(jantaresList);
      }

      setState(() {
        _encontros = todosEncontros;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar encontros: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas'),
        backgroundColor: AppColors.creme,
        foregroundColor: AppColors.tinta,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _encontros.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.tan,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma conversa ainda',
                    style: AppTypography.serif(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Participe de um jantar para começar a conversar',
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(fontSize: 14, color: AppColors.bege),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarEncontros,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _encontros.length,
                itemBuilder: (context, index) {
                  final encontro = _encontros[index];
                  return _buildChatCard(encontro);
                },
              ),
            ),
    );
  }

  Widget _buildChatCard(dynamic encontro) {
    final nomeCardapio = encontro['nm_cardapio'] ?? 'Jantar';
    final idEncontro = encontro['id_encontro'];
    final dataHora = encontro['hr_encontro'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.marfim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordaSuave),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.tan,
          radius: 28,
          child: Icon(Icons.restaurant, color: AppColors.tanTexto, size: 28),
        ),
        title: Text(
          nomeCardapio,
          style: AppTypography.serif(fontSize: 16),
        ),
        subtitle: Text(
          _formatarData(dataHora),
          style: AppTypography.sans(color: AppColors.bege, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.bege),
        onTap: () {
          if (idEncontro != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaChat(
                  encontroId: int.parse(idEncontro.toString()),
                  encontroNome: nomeCardapio,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatarData(String dataHora) {
    if (dataHora.isEmpty) return 'Data não disponível';

    try {
      final data = DateTime.parse(dataHora);
      final agora = DateTime.now();
      final diferenca = agora.difference(data);

      if (diferenca.inDays == 0) {
        return 'Hoje às ${data.hour}:${data.minute.toString().padLeft(2, '0')}';
      } else if (diferenca.inDays == 1) {
        return 'Ontem';
      } else if (diferenca.inDays < 7) {
        return '${diferenca.inDays} dias atrás';
      } else {
        return '${data.day}/${data.month}/${data.year}';
      }
    } catch (e) {
      return dataHora;
    }
  }
}
