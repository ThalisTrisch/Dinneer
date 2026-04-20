import 'package:flutter/material.dart';
import '../service/refeicao/cardapioService.dart';

class TelaMeusJantares extends StatefulWidget {
  final int idLocal;
  final int idUsuario;

  const TelaMeusJantares({
    super.key,
    required this.idLocal,
    required this.idUsuario,
  });

  @override
  State<TelaMeusJantares> createState() => _TelaMeusJantaresState();
}

class _TelaMeusJantaresState extends State<TelaMeusJantares> {
  bool carregando = true;
  List<dynamic> jantares = [];

  @override
  void initState() {
    print("entrou aqui");
    super.initState();
    _carregarJantares();
  }

  Future<void> _carregarJantares() async {
    try {
      print("Comecando a carregar dados");

      final resposta = await CardapioService.getMeuCardapio(widget.idLocal);

      print("jantares carregados");

      print(resposta);

      setState(() {
        jantares = resposta["dados"] ?? [];
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  void _confirmarDeleteJantar(int idJantar) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir jantar"),
        content: const Text("Tem certeza que deseja excluir este jantar?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);

              print("deletando jantar id ");
              print(idJantar);
              await CardapioService.deleteJantar(idJantar);
              print("jantar deletado");
              _carregarJantares();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Jantares"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : jantares.isEmpty
              ? const Center(child: Text("Nenhum jantar cadastrado."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jantares.length,
                  itemBuilder: (_, index) {
                    final jantar = jantares[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jantar["nm_cardapio"] ?? "Jantar sem título",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Data: ${jantar["ds_cardapio"] ?? "--"}",
                              style: const TextStyle(fontSize: 14),
                            ),

                            const SizedBox(height: 6),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Excluir"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _confirmarDeleteJantar(jantar["id_cardapio"]);
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
