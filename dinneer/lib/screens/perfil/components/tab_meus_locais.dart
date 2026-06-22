import 'package:flutter/material.dart';
import 'package:dinneer/service/local/LocalService.dart';
import 'package:dinneer/screens/tela_criar_jantar.dart';
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class TabMeusLocais extends StatefulWidget {
  final String idUsuario;

  const TabMeusLocais({super.key, required this.idUsuario});

  @override
  State<TabMeusLocais> createState() => TabMeusLocaisState();
}

class TabMeusLocaisState extends State<TabMeusLocais> {
  List<dynamic> meusLocais = [];
  bool carregandoLocais = true;

  @override
  void initState() {
    super.initState();
    carregarLocais();
  }

  Future<void> carregarLocais() async {
    if (!mounted) return;
    setState(() => carregandoLocais = true);

    try {
      final resposta = await LocalService.getMeusLocais(widget.idUsuario);

      if (!mounted) return;
      setState(() {
        meusLocais = resposta['dados'] ?? [];
        carregandoLocais = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregandoLocais = false);
    }
  }

  void _confirmarDeleteLocal(int idLocal) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Excluir local"),
          content: const Text("Tem certeza que deseja excluir este local?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await LocalService.deleteLocal(idLocal.toString());
                  if (!mounted) return;
                  await carregarLocais();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Local excluído.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Erro ao excluir."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                "Excluir",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregandoLocais) {
      return const Center(child: CircularProgressIndicator());
    }

    if (meusLocais.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_outlined, size: 60, color: AppColors.tan),
            const SizedBox(height: 16),
            Text(
              "Você ainda não cadastrou nenhum local.",
              style: AppTypography.sans(color: AppColors.bege),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 80, left: 20, right: 20),
      itemCount: meusLocais.length,
      itemBuilder: (context, index) {
        final local = meusLocais[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: AppColors.marfim,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.bordaSuave),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.terracotaSuave,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.terracota,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CEP: ${local['nu_cep']}",
                            style: AppTypography.serif(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Número: ${local['nu_casa']}",
                            style: AppTypography.sans(
                              fontSize: 14,
                              color: AppColors.bege,
                            ),
                          ),
                          if (local['dc_complemento'] != null &&
                              local['dc_complemento'].toString().isNotEmpty)
                            Text(
                              "${local['dc_complemento']}",
                              style: AppTypography.sans(
                                fontSize: 12,
                                color: AppColors.bege,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        int idLocal =
                            int.tryParse(local['id_local'].toString()) ?? 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaCriarJantar(
                              idUsuario: widget.idUsuario,
                              idLocalPreSelecionado: idLocal,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: const Text("Novo Jantar"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.terracota,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmarDeleteLocal(
                        int.tryParse(local['id_local'].toString()) ?? 0,
                      ),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: "Excluir Local",
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
