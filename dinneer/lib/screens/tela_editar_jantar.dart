import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/campo_de_texto.dart';
import '../service/refeicao/cardapioService.dart';
import '../service/refeicao/Cardapio.dart';

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

  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (imagem != null) setState(() => _novaImagem = File(imagem.path));
  }

  Future<String> _uploadNovaImagem() async {
    if (_novaImagem == null) return widget.jantar.urlFoto ?? "";

    String nomeArquivo =
        "jantar_edit_${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child(
      'jantares/$nomeArquivo',
    );
    final metadata = SettableMetadata(contentType: "image/jpeg");
    UploadTask task = ref.putFile(_novaImagem!, metadata);
    await task.whenComplete(() {});
    return await ref.getDownloadURL();
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Jantar atualizado!")));
          Navigator.pop(
            context,
            true,
          ); // Retorna true para atualizar a tela anterior
        }
      } else {
        throw Exception("Erro no servidor.");
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
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
            GestureDetector(
              onTap: _escolherImagem,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: _novaImagem != null
                      ? DecorationImage(
                          image: FileImage(_novaImagem!),
                          fit: BoxFit.cover,
                        )
                      : (widget.jantar.urlFoto != null
                            ? DecorationImage(
                                image: NetworkImage(widget.jantar.urlFoto!),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: (_novaImagem == null && widget.jantar.urlFoto == null)
                    ? const Center(
                        child: Icon(Icons.camera_alt, color: Colors.grey),
                      )
                    : null,
              ),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _estaCarregando ? null : _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _estaCarregando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "SALVAR ALTERAÇÕES",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
