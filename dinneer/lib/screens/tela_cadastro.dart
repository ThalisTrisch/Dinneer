import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/mensagens.dart';
import '../service/usuario/UsuarioService.dart';
import '../service/storage/StorageService.dart';
import 'cadastro/components/etapa_credenciais.dart';
import 'cadastro/components/etapa_dados_pessoais.dart';

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

  final StorageService _storage = StorageService();

  File? _imagemSelecionada;

  bool _emailPermitido(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+$');
    return regex.hasMatch(email.trim());
  }

  Future<void> _escolherImagem() async {
    try {
      final imagem = await _storage.escolherImagem(
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (imagem != null) {
        setState(() {
          _imagemSelecionada = imagem;
        });
      }
    } catch (e) {
      debugPrint("Erro ao escolher imagem: $e");
    }
  }

  Future<String?> _uploadImagemFirebase(File imagem) async {
    try {
      return await _storage.uploadImagem(
        imagem,
        pasta: 'perfis',
        prefixo: 'perfil',
      );
    } catch (e, stack) {
      debugPrint("ERRO CRÍTICO NO UPLOAD: $e");
      debugPrint(stack.toString());
      return null;
    }
  }

  void _proximaEtapa() {
    final email = _emailController.text.trim();

    if (email.isEmpty || _senhaController.text.isEmpty) {
      Mensagens.neutra(context, 'Preencha email e senha.');
      return;
    }
    if (!_emailPermitido(email)) {
      Mensagens.erro(context, 'Informe um email com @ e domínio.');
      return;
    }
    if (_senhaController.text == _confirmarSenhaController.text) {
      setState(() => _etapaAtual = 2);
    } else {
      Mensagens.erro(context, 'As senhas não coincidem.');
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
          Mensagens.sucesso(context, "Cadastro realizado com sucesso.");
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
    if (mounted) Mensagens.erro(context, mensagem);
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
            child: _etapaAtual == 1
                ? EtapaCredenciais(
                    emailController: _emailController,
                    senhaController: _senhaController,
                    confirmarSenhaController: _confirmarSenhaController,
                    onContinuar: _proximaEtapa,
                  )
                : EtapaDadosPessoais(
                    nomeController: _nomeController,
                    sobrenomeController: _sobrenomeController,
                    cpfController: _cpfController,
                    imagemSelecionada: _imagemSelecionada,
                    estaCarregando: _estaCarregando,
                    onEscolherImagem: _escolherImagem,
                    onCadastrar: _fazerCadastro,
                  ),
          ),
        ),
      ),
    );
  }
}
