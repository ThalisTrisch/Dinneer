import 'package:flutter/material.dart';
import '../widgets/campo_de_texto.dart';
import '../widgets/mensagens.dart';
import '../widgets/botao_primario.dart';
import '../service/local/LocalService.dart';

class TelaCriarLocal extends StatefulWidget {
  final int idUsuario;

  const TelaCriarLocal({super.key, required this.idUsuario});

  @override
  State<TelaCriarLocal> createState() => _TelaCriarLocalState();
}

class _TelaCriarLocalState extends State<TelaCriarLocal> {
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cnpjController = TextEditingController();
  bool _estaCarregando = false;

  void _criarLocal() async {
    if (_cepController.text.isEmpty || _numeroController.text.isEmpty) {
      Mensagens.neutra(context, "CEP e Número são obrigatórios.");
      return;
    }

    setState(() => _estaCarregando = true);

    final dados = {
      'id_usuario': widget.idUsuario.toString(),
      'nu_cep': _cepController.text,
      'nu_casa': _numeroController.text,
      'dc_complemento': _complementoController.text,
      'nu_cnpj': _cnpjController.text,
    };

    try {
      final res = await LocalService.createLocal(dados);

      if (res != null && (res['registros'] == 1 || (res['dados'] != null))) {
        if (mounted) {
          Mensagens.sucesso(context, "Local adicionado!");
          Navigator.pop(context, true);
        }
      } else {
        _mostrarErro("Erro ao criar: ${res?['Mensagem']}");
      }
    } catch (e) {
      _mostrarErro("Erro de conexão: $e");
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarErro(String msg) {
    if (mounted) Mensagens.erro(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Adicionar Novo Local",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Endereço",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CampoDeTextoCustomizado(controller: _cepController, dica: "CEP"),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _numeroController,
              dica: "Número da Casa",
            ),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _complementoController,
              dica: "Complemento (Ex: Casa de fundos)",
            ),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _cnpjController,
              dica: "CNPJ (Opcional)",
            ),
            const SizedBox(height: 32),
            BotaoPrimario(
              texto: "SALVAR LOCAL",
              onPressed: _criarLocal,
              estaCarregando: _estaCarregando,
            ),
          ],
        ),
      ),
    );
  }
}
