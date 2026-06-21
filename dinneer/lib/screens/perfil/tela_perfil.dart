import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/service/usuario/UsuarioService.dart';
import 'package:dinneer/service/storage/StorageService.dart';
import 'package:dinneer/widgets/mensagens.dart';

import 'package:dinneer/screens/tela_criar_local.dart';

import 'components/perfil_header.dart';
import 'components/tab_avaliacoes.dart';
import 'components/tab_meus_locais.dart';
import 'package:dinneer/theme/app_colors.dart';

class TelaPerfil extends StatefulWidget {
  final Map<String, dynamic> dadosUsuario;

  const TelaPerfil({super.key, required this.dadosUsuario});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> with TickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<TabMeusLocaisState> _meusLocaisKey =
      GlobalKey<TabMeusLocaisState>();

  String? idUsuario;
  String? fotoUrlAtual;
  String nomeUsuario = "Usuário";
  String emailUsuario = "@usuario";
  bool _enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _inicializarDadosUsuario();
  }

  void _inicializarDadosUsuario() {
    setState(() {
      nomeUsuario = widget.dadosUsuario['nm_usuario'] ?? 'Usuário';
      emailUsuario = widget.dadosUsuario['vl_email'] ?? '@usuario';

      final rawFoto = widget.dadosUsuario['vl_foto'];
      if (rawFoto != null &&
          rawFoto.toString().isNotEmpty &&
          rawFoto.toString() != 'null') {
        fotoUrlAtual = rawFoto.toString();
      }
    });

    if (widget.dadosUsuario['id_usuario'] != null) {
      idUsuario = widget.dadosUsuario['id_usuario'].toString();
    } else {
      _carregarIdUsuarioSessao();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarIdUsuarioSessao() async {
    final id = await SessionService.pegarUsuarioId();
    if (mounted && id != null) {
      setState(() => idUsuario = id);
    }
  }

  final StorageService _storage = StorageService();

  Future<void> _alterarFotoPerfil() async {
    try {
      final imagem = await _storage.escolherImagem(
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (imagem != null) {
        setState(() => _enviandoFoto = true);
        await _uploadEAtualizarFoto(imagem);
      }
    } catch (e) {
      setState(() => _enviandoFoto = false);
    }
  }

  Future<void> _uploadEAtualizarFoto(File imagem) async {
    try {
      String novaUrl = await _storage.uploadImagem(
        imagem,
        pasta: 'perfis',
        prefixo: 'perfil',
        timeout: const Duration(seconds: 15),
      );

      if (idUsuario != null) {
        await UsuarioService.atualizarFotoPerfil(idUsuario!, novaUrl);
      }

      if (mounted) {
        setState(() {
          fotoUrlAtual = novaUrl;
          _enviandoFoto = false;
        });
        Mensagens.sucesso(context, "Foto atualizada!");
      }
    } catch (e) {
      debugPrint("Erro upload: $e");
      if (mounted) {
        setState(() => _enviandoFoto = false);
        Mensagens.erro(context, "Erro ao enviar foto.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (idUsuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.creme,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaCriarLocal(idUsuario: int.parse(idUsuario!)),
            ),
          ).then((result) {
            if (result == true) {
              _meusLocaisKey.currentState?.carregarLocais();
            }
          });
        },
        label: const Text(
          "Adicionar local",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        backgroundColor: AppColors.terracota,
      ),

      body: CustomScrollView(
        slivers: [
          PerfilHeader(
            nomeUsuario: nomeUsuario,
            emailUsuario: emailUsuario,
            fotoUrl: fotoUrlAtual,
            isUploading: _enviandoFoto,
            onCameraTap: _alterarFotoPerfil,
          ),

          SliverPersistentHeader(
            delegate: SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.terracota,
                unselectedLabelColor: AppColors.bege,
                indicatorColor: AppColors.terracota,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Avaliações"),
                  Tab(text: "Meus Locais"),
                ],
              ),
            ),
            pinned: true,
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                TabAvaliacoes(idUsuario: int.parse(idUsuario!)),

                TabMeusLocais(key: _meusLocaisKey, idUsuario: idUsuario!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
