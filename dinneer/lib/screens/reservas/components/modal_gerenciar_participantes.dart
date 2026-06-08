import 'package:flutter/material.dart';

import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/http/HttpService.dart';
import 'package:dinneer/config/api_config.dart';
import 'package:dinneer/screens/tela_perfil_publico.dart';
import 'item_participante.dart';

/// Bottom sheet que lista os participantes de um jantar e permite ao
/// anfitrião aprovar ou rejeitar solicitações de reserva.
///
/// Faz as chamadas de rede via [HttpService] e notifica a tela de reservas
/// através de [onAtualizar] quando o status de algum participante muda.
class ModalGerenciarParticipantes extends StatefulWidget {
  final Cardapio jantar;
  final VoidCallback onAtualizar;

  const ModalGerenciarParticipantes({
    super.key,
    required this.jantar,
    required this.onAtualizar,
  });

  @override
  State<ModalGerenciarParticipantes> createState() =>
      _ModalGerenciarParticipantesState();
}

class _ModalGerenciarParticipantesState
    extends State<ModalGerenciarParticipantes> {
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
      final endpoint = ApiConfig.getEndpoint("encontro/EncontroController.php");

      final res = await http.get(
        endpoint,
        "getParticipantes",
        queryParams: {"id_encontro": widget.jantar.idEncontro.toString()},
      );

      if (mounted) {
        setState(() {
          participantes = res['dados'] ?? [];
          carregando = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar participantes: $e");
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _alterarStatus(int idConvidado, bool aprovar) async {
    final operacao = aprovar ? "aprovarReserva" : "rejeitarReserva";
    setState(() => carregando = true);

    try {
      final endpoint = ApiConfig.getEndpoint("encontro/EncontroController.php");
      await http.post(
        endpoint,
        operacao,
        body: {
          "id_encontro": widget.jantar.idEncontro.toString(),
          "id_convidado": idConvidado.toString(),
        },
      );

      await _carregarParticipantes();
      widget.onAtualizar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
        setState(() => carregando = false);
      }
    }
  }

  void _abrirPerfil(Map<String, dynamic> participante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaPerfilPublico(
          idUsuario: int.parse(participante['id_usuario'].toString()),
          nomeUsuario: participante['nome_completo'],
          fotoUrl: participante['vl_foto'],
        ),
      ),
    );
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
                    const Text(
                      "Gerenciar Convidados",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      widget.jantar.nmCardapio,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: carregando
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : participantes.isEmpty
                ? const Center(child: Text("Lista de convidados vazia."))
                : ListView.builder(
                    itemCount: participantes.length,
                    itemBuilder: (context, index) {
                      final p = Map<String, dynamic>.from(participantes[index]);
                      final int idUsuario = int.parse(
                        p['id_usuario'].toString(),
                      );

                      return ItemParticipante(
                        participante: p,
                        onAbrirPerfil: () => _abrirPerfil(p),
                        onAprovar: () => _alterarStatus(idUsuario, true),
                        onRejeitar: () => _alterarStatus(idUsuario, false),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
