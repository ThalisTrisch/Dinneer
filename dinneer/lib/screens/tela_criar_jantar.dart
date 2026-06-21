import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/campo_de_texto.dart';
import '../widgets/mensagens.dart';
import '../widgets/botao_primario.dart';
import '../service/refeicao/cardapioService.dart';
import '../service/storage/StorageService.dart';
import 'criar_jantar/components/seletor_imagem.dart';
import 'criar_jantar/components/seletores_data_hora.dart';

class TelaCriarJantar extends StatefulWidget {
  final String idUsuario;
  final int? idLocalPreSelecionado;

  const TelaCriarJantar({
    super.key,
    required this.idUsuario,
    this.idLocalPreSelecionado,
  });

  @override
  State<TelaCriarJantar> createState() => _TelaCriarJantarState();
}

class _TelaCriarJantarState extends State<TelaCriarJantar> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _vagasController = TextEditingController();

  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  File? _imagemSelecionada;
  bool _estaCarregando = false;

  final StorageService _storage = StorageService();

  Future<void> _escolherImagem() async {
    try {
      final imagem = await _storage.escolherImagem(
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (imagem != null) {
        setState(() => _imagemSelecionada = imagem);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String?> _uploadImagemFirebase(File imagem) async {
    try {
      return await _storage.uploadImagem(
        imagem,
        pasta: 'jantares',
        prefixo: 'jantar',
        timeout: const Duration(seconds: 20),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (data != null) setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) setState(() => _horaSelecionada = hora);
  }

  void _criarJantar() async {
    if (_tituloController.text.isEmpty ||
        _precoController.text.isEmpty ||
        _dataSelecionada == null ||
        _horaSelecionada == null) {
      _mostrarErro("Preencha todos os campos principais.");
      return;
    }

    if (widget.idLocalPreSelecionado == null) {
      _mostrarErro(
        "Erro: Local não identificado. Crie o jantar a partir da aba Meus Locais.",
      );
      return;
    }

    setState(() => _estaCarregando = true);

    String? urlFoto;
    if (_imagemSelecionada != null) {
      urlFoto = await _uploadImagemFirebase(_imagemSelecionada!);
      if (urlFoto == null) {
        _mostrarErro("Erro ao enviar imagem.");
        setState(() => _estaCarregando = false);
        return;
      }
    }

    final dataHora = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    final dados = {
      'id_usuario': widget.idUsuario.toString(),
      'nm_cardapio': _tituloController.text,
      'ds_cardapio': _descricaoController.text,
      'preco_refeicao': _precoController.text.replaceAll(',', '.'),
      'nu_max_convidados': _vagasController.text,
      'hr_encontro': dataHora.toIso8601String(),
      'vl_foto': urlFoto ?? '',
      'id_local': widget.idLocalPreSelecionado.toString(),
    };

    try {
      final res = await CardapioService.createJantar(dados);

      if (res != null && (res['registros'] == 1 || res['dados'] != null)) {
        if (mounted) {
          Mensagens.sucesso(context, "Jantar publicado!");
          Navigator.pop(context, true);
        }
      } else {
        _mostrarErro("Erro no servidor: ${res?['Mensagem']}");
      }
    } catch (e) {
      _mostrarErro("Erro: $e");
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
        title: const Text("Criar Novo Jantar"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SeletorImagem(
              imagemLocal: _imagemSelecionada,
              onTocar: _escolherImagem,
            ),
            const SizedBox(height: 24),

            CampoDeTextoCustomizado(
              controller: _tituloController,
              dica: "Nome do Prato",
            ),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _descricaoController,
              dica: "Descrição",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoDeTextoCustomizado(
                    controller: _precoController,
                    dica: "Preço",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoDeTextoCustomizado(
                    controller: _vagasController,
                    dica: "Vagas",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SeletoresDataHora(
              data: _dataSelecionada,
              hora: _horaSelecionada,
              onSelecionarData: _selecionarData,
              onSelecionarHora: _selecionarHora,
            ),

            const SizedBox(height: 32),
            BotaoPrimario(
              texto: "PUBLICAR JANTAR",
              onPressed: _criarJantar,
              estaCarregando: _estaCarregando,
            ),
          ],
        ),
      ),
    );
  }
}
