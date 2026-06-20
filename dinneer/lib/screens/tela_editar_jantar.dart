import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/campo_de_texto.dart';
import '../widgets/mensagens.dart';
import '../widgets/botao_primario.dart';
import '../service/refeicao/cardapioService.dart';
import '../service/refeicao/Cardapio.dart';
import '../service/storage/StorageService.dart';
import 'criar_jantar/components/seletor_imagem.dart';

class TelaEditarJantar extends StatefulWidget {
  final Cardapio jantar;

  const TelaEditarJantar({super.key, required this.jantar});

  @override
  State<TelaEditarJantar> createState() => _TelaEditarJantarState();
}

class _TelaEditarJantarState extends State<TelaEditarJantar> {
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _vagasController;
  late TextEditingController _cepController;
  late TextEditingController _numeroController;

  late DateTime _dataSelecionada;
  late TimeOfDay _horaSelecionada;
  File? _novaImagem;
  bool _estaCarregando = false;

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.jantar.nmCardapio);
    _descricaoController = TextEditingController(
      text: widget.jantar.dsCardapio,
    );
    _precoController = TextEditingController(
      text: widget.jantar.precoRefeicao.toString(),
    );
    _vagasController = TextEditingController(
      text: widget.jantar.nuMaxConvidados.toString(),
    );
    _cepController = TextEditingController(text: widget.jantar.nuCep);
    _numeroController = TextEditingController(text: widget.jantar.nuCasa);

    _dataSelecionada = widget.jantar.hrEncontro;
    _horaSelecionada = TimeOfDay.fromDateTime(widget.jantar.hrEncontro);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _vagasController.dispose();
    _cepController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    final imagem = await _storage.escolherImagem(imageQuality: 70);
    if (imagem != null) setState(() => _novaImagem = imagem);
  }

  Future<String> _uploadNovaImagem() async {
    if (_novaImagem == null) return widget.jantar.urlFoto ?? "";

    return await _storage.uploadImagem(
      _novaImagem!,
      pasta: 'jantares',
      prefixo: 'jantar_edit',
    );
  }

  void _salvarAlteracoes() async {
    setState(() => _estaCarregando = true);

    try {
      String urlFinal = await _uploadNovaImagem();

      final dataHora = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      final dados = {
        'id_cardapio': widget.jantar.idRefeicao.toString(),
        'nm_cardapio': _tituloController.text,
        'ds_cardapio': _descricaoController.text,
        'preco_refeicao': _precoController.text,
        'nu_max_convidados': _vagasController.text,
        'nu_cep': _cepController.text,
        'nu_casa': _numeroController.text,
        'hr_encontro': dataHora.toIso8601String(),
        'vl_foto': urlFinal,
      };

      final res = await CardapioService.updateJantar(dados);

      if (res != null && (res['registros'] == 1 || res['dados'] != null)) {
        if (mounted) {
          Mensagens.neutra(context, "Jantar atualizado!");
          Navigator.pop(
            context,
            true,
          );
        }
      } else {
        throw Exception("Erro no servidor.");
      }
    } catch (e) {
      if (mounted) Mensagens.erro(context, "Erro: $e");
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Jantar"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SeletorImagem(
              imagemLocal: _novaImagem,
              urlRede: widget.jantar.urlFoto,
              onTocar: _escolherImagem,
            ),
            const SizedBox(height: 24),
            CampoDeTextoCustomizado(
              controller: _tituloController,
              dica: "Título",
            ),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _descricaoController,
              dica: "Descrição",
            ),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _cepController,
              dica: "CEP",
            ),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(
              controller: _numeroController,
              dica: "Número",
            ),
            const SizedBox(height: 32),
            BotaoPrimario(
              texto: "SALVAR ALTERAÇÕES",
              onPressed: _salvarAlteracoes,
              estaCarregando: _estaCarregando,
            ),
          ],
        ),
      ),
    );
  }
}
