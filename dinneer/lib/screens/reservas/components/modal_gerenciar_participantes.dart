import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/http/HttpService.dart';
import 'package:dinneer/screens/perfil_publico/tela_perfil_publico.dart';

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
      final res = await http.get(
        "encontro/EncontroController.php",
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
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _alterarStatus(int idConvidado, bool aprovar) async {
    final operacao = aprovar ? "aprovarReserva" : "rejeitarReserva";
    setState(() => carregando = true);

    try {
      await http.post(
        "encontro/EncontroController.php",
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
                      final p = participantes[index];
                      final bool pendente = p['fl_status'] == 'P';
                      final int idUsuario = int.parse(
                        p['id_usuario'].toString(),
                      );
                      final String nome = p['nome_completo'];
                      final String? foto = p['vl_foto'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: pendente
                            ? Colors.orange.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: pendente
                                ? Colors.orange.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
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
                                  backgroundImage: (foto != null && foto != "")
                                      ? NetworkImage(foto)
                                      : null,
                                  child: (foto == null || foto == "")
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        pendente
                                            ? "Solicitação de +${p['nu_dependentes']}"
                                            : "Confirmado +${p['nu_dependentes']}",
                                        style: TextStyle(
                                          color: pendente
                                              ? Colors.orange[800]
                                              : Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (pendente) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                    onPressed: () =>
                                        _alterarStatus(idUsuario, true),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                    onPressed: () =>
                                        _alterarStatus(idUsuario, false),
                                  ),
                                ] else ...[
                                  const Icon(Icons.check, color: Colors.green),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
