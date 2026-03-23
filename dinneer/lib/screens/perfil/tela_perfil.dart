import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/service/usuario/UsuarioService.dart';

import 'package:dinneer/screens/tela_criar_local.dart';

import 'components/perfil_header.dart';
import 'components/tab_avaliacoes.dart';
import 'components/tab_meus_locais.dart';

class TelaPerfil extends StatefulWidget {
  final Map<String, dynamic> dadosUsuario;

  const TelaPerfil({super.key, required this.dadosUsuario});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final GlobalKey<TabMeusLocaisState> _meusLocaisKey = GlobalKey<TabMeusLocaisState>();
  
  String? idUsuario;
  String? fotoUrlAtual;
  String nomeUsuario = "Usuário";
  String emailUsuario = "@usuario";
  bool _enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    // Agora temos apenas 2 abas: Avaliações e Meus Locais
    _tabController = TabController(length: 2, vsync: this);
    _inicializarDadosUsuario();
  }

  void _inicializarDadosUsuario() {
    setState(() {
      nomeUsuario = widget.dadosUsuario['nm_usuario'] ?? 'Usuário';
      emailUsuario = widget.dadosUsuario['vl_email'] ?? '@usuario';
      
      final rawFoto = widget.dadosUsuario['vl_foto'];
      if (rawFoto != null && rawFoto.toString().isNotEmpty && rawFoto.toString() != 'null') {
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

  Future<void> _alterarFotoPerfil() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (imagem != null) {
        setState(() => _enviandoFoto = true);
        await _uploadEAtualizarFoto(File(imagem.path));
      }
    } catch (e) {
      setState(() => _enviandoFoto = false);
    }
  }

  Future<void> _uploadEAtualizarFoto(File imagem) async {
    try {
      String nomeArquivo = "perfil_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child('perfis/$nomeArquivo');
      
      final metadata = SettableMetadata(contentType: "image/jpeg");
      
      UploadTask task = ref.putFile(imagem, metadata);
      
      await task.whenComplete(() {}).timeout(
        const Duration(seconds: 15),
        onTimeout: () { throw Exception("Tempo limite excedido."); },
      );

      String novaUrl = await ref.getDownloadURL();

      if (idUsuario != null) {
         await UsuarioService.atualizarFotoPerfil(idUsuario!, novaUrl);
      }

      if (mounted) {
        setState(() {
          fotoUrlAtual = novaUrl;
          _enviandoFoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto atualizada!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Erro upload: $e");
      if (mounted) {
        setState(() => _enviandoFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao enviar foto."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (idUsuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      
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
        label: const Text("Adicionar local", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        backgroundColor: Colors.black,
      ),

      body: CustomScrollView(
        slivers: [
          // 1. Cabeçalho (Componente Separado)
          PerfilHeader(
            nomeUsuario: nomeUsuario,
            emailUsuario: emailUsuario,
            fotoUrl: fotoUrlAtual,
            isUploading: _enviandoFoto,
            onCameraTap: _alterarFotoPerfil,
          ),
          
          // 2. Barra de Abas Fixa
          SliverPersistentHeader(
            delegate: SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Avaliações"),
                  Tab(text: "Meus Locais"),
                ],
              ),
            ),
            pinned: true,
          ),

          // 3. Conteúdo das Abas
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba 1: Avaliações (Com a média no topo)
                TabAvaliacoes(idUsuario: int.parse(idUsuario!)), 
                
                // Aba 2: Meus Locais
                TabMeusLocais(
                  key: _meusLocaisKey, 
                  idUsuario: idUsuario!
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
