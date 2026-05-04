import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/campo_de_texto.dart';
import '../service/usuario/UsuarioService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  int _etapaAtual = 1;
  bool _estaCarregando = false;

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _cpfController = TextEditingController();

  File? _imagemSelecionada;

  // Seleciona e PADRONIZA a imagem
  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Qualidade 80%
        maxWidth: 1080, // Largura máxima HD
      );
      if (imagem != null) {
        setState(() {
          _imagemSelecionada = File(imagem.path);
        });
      }
    } catch (e) {
      debugPrint("Erro ao escolher imagem: $e");
    }
  }

  Future<String?> _uploadImagemFirebase(File imagem) async {
    try {
      final String nomeArquivo = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final Reference ref = FirebaseStorage.instance.ref().child(
        "perfis/$nomeArquivo",
      );

      final metadata = SettableMetadata(contentType: "image/jpeg");

      debugPrint("Iniciando upload da imagem para: perfis/$nomeArquivo");

      final UploadTask task = ref.putFile(imagem, metadata);
      final TaskSnapshot snap = await task.whenComplete(() {});

      final String url = await snap.ref.getDownloadURL();

      debugPrint("Upload concluído. URL: $url");

      return url;
    } catch (e, stack) {
      debugPrint("ERRO CRÍTICO NO UPLOAD: $e");
      debugPrint(stack.toString());
      return null;
    }
  }

  void _proximaEtapa() {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha email e senha.')));
      return;
    }
    if (_senhaController.text == _confirmarSenhaController.text) {
      setState(() => _etapaAtual = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _fazerCadastro() async {
    if (_nomeController.text.isEmpty || _cpfController.text.isEmpty) {
      _mostrarErro("Nome e CPF são obrigatórios.");
      return;
    }

    setState(() => _estaCarregando = true);

    String? urlFotoFirebase;

    if (_imagemSelecionada != null) {
      urlFotoFirebase = await _uploadImagemFirebase(_imagemSelecionada!);

      if (urlFotoFirebase == null) {
        _mostrarErro("Falha ao enviar a foto. Verifique sua internet.");
        setState(() => _estaCarregando = false);
        return;
      }
    }

    final Map<String, dynamic> dadosUsuario = {
      "nm_usuario": _nomeController.text.trim(),
      "nm_sobrenome": _sobrenomeController.text.trim(),
      "vl_email": _emailController.text.trim(),
      "vl_senha": _senhaController.text,
      "nu_cpf": _cpfController.text.trim(),
      "vl_foto": urlFotoFirebase ?? "",
    };

    debugPrint("Enviando usuário ao backend: $dadosUsuario");

    try {
      final resposta = await UsuarioService.createUsuario(dadosUsuario);

      if (resposta != null &&
          (resposta['dados'] != null || resposta['Mensagem'] == 'Sucesso')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cadastro realizado com sucesso."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        _mostrarErro(resposta?['Mensagem'] ?? "Erro desconhecido no backend.");
      }
    } catch (e, stack) {
      debugPrint("ERRO AO CADASTRAR: $e");
      debugPrint(stack.toString());
      _mostrarErro("Erro ao conectar-se ao servidor.");
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), backgroundColor: Colors.redAccent),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            if (_etapaAtual == 2) {
              setState(() => _etapaAtual = 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Cadastro $_etapaAtual/2',
          style: const TextStyle(color: Colors.black54),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: _etapaAtual == 1 ? _buildEtapa1() : _buildEtapa2(),
          ),
        ),
      ),
    );
  }

  Widget _buildEtapa1() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.restaurant_menu, size: 80, color: Colors.black54),
        const SizedBox(height: 20),
        const Text(
          'DINNEER',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 40),
        CampoDeTextoCustomizado(controller: _emailController, dica: 'Email'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _senhaController,
          dica: 'Senha',
          textoObscuro: true,
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _confirmarSenhaController,
          dica: 'Confirmar Senha',
          textoObscuro: true,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proximaEtapa,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'CONTINUAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLinkLogin(),
      ],
    );
  }

  Widget _buildEtapa2() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: _imagemSelecionada != null
                  ? FileImage(_imagemSelecionada!)
                  : null,
              child: _imagemSelecionada == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                  : null,
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _escolherImagem,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        CampoDeTextoCustomizado(controller: _nomeController, dica: 'Nome'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _sobrenomeController,
          dica: 'Sobrenome',
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _cpfController,
          dica: 'CPF (apenas números)',
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _estaCarregando ? null : _fazerCadastro,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _estaCarregando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : const Text(
                    'CADASTRAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLinkLogin(),
      ],
    );
  }

  Widget _buildLinkLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Já tem login? ', style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            'Entre',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
