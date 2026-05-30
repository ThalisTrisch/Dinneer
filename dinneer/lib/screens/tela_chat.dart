import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/message_model.dart';
import '../service/chat/chat_service.dart';
import '../service/sessao/SessionService.dart';
import '../service/notification/notification_service.dart';
import 'chat/components/message_bubble.dart';
import 'chat/components/campo_mensagem.dart';

import 'dart:io';

class TelaChat extends StatefulWidget {
  final int encontroId;
  final String encontroNome;
  final String imagemSelecionada;

  const TelaChat({
    super.key,
    required this.encontroId,
    required this.encontroNome,
    this.imagemSelecionada = '',
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _userId;
  String? _userName;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _userId != null) {
      _chatService.markAsRead(widget.encontroId, _userId!);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final dadosUsuario = await SessionService.getUsuario();

      if (mounted) {
        setState(() {
          _userId = dadosUsuario['id_usuario']?.toString();
          _userName = dadosUsuario['nm_usuario'] ?? 'Usuário';
        });

        if (_userId != null) {
          _chatService.markAsRead(widget.encontroId, _userId!);
        }
      }
    } catch (erro) {
      debugPrint('Erro ao carregar dados do usuário: $erro');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados do usuário'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Rola a lista para o final (topo, pois a lista é invertida) após enviar.
  /// O pequeno delay aguarda a mensagem ser adicionada à lista.
  void _rolarParaFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    // Validação: não envia se o texto estiver vazio ou usuário não carregado
    if (_messageController.text.trim().isEmpty || _userId == null) return;

    final textoMensagem = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        encontroId: widget.encontroId,
        senderId: _userId!,
        senderName: _userName!,
        text: textoMensagem,
      );

      NotificationService.sendChatNotification(
        encontroId: widget.encontroId,
        senderId: _userId!,
        senderName: _userName!,
        messageText: textoMensagem,
      );

      _rolarParaFinal();
    } catch (erro) {
      debugPrint('Erro ao enviar mensagem: $erro');

      // Restaura o texto no campo se falhar
      _messageController.text = textoMensagem;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar mensagem. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Envia uma imagem no chat
  ///
  /// Abre o seletor de imagens, faz upload para o Firebase Storage
  /// e envia a URL da imagem como mensagem no chat
  Future<void> _sendImage() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde carregar dados do usuário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 1. Abre o seletor de imagens
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // Usuário cancelou a seleção
        return;
      }

      // Mostra indicador de carregamento
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Enviando imagem...'),
              ],
            ),
            duration: Duration(minutes: 1),
          ),
        );
      }

      // 2. Prepara o arquivo para upload
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_userId.jpg';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(widget.encontroId.toString())
          .child(fileName);

      // 3. Faz upload para o Firebase Storage
      late final UploadTask uploadTask;

      if (kIsWeb) {
        // Na Web, usa putData com bytes
        final bytes = await pickedFile.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // No mobile, usa putFile
        final File imageFile = File(pickedFile.path);
        uploadTask = storageRef.putFile(imageFile);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Envia a mensagem com a URL da imagem
      await _chatService.sendMessage(
        encontroId: widget.encontroId,
        senderId: _userId!,
        senderName: _userName!,
        text: '', // Texto vazio para mensagens apenas de imagem
        imageUrl: downloadUrl,
      );

      // Remove o indicador de carregamento
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _rolarParaFinal();
      }
    } catch (e) {
      debugPrint('Erro ao enviar imagem: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.encontroNome),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.encontroId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar mensagens',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final listaMensagens = snapshot.data ?? [];

                if (listaMensagens.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nSeja o primeiro a enviar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: listaMensagens.length,
                  itemBuilder: (context, index) {
                    final mensagem = listaMensagens[index];
                    final ehMinhaMensagem = mensagem.senderId == _userId;

                    return MessageBubble(
                      mensagem: mensagem,
                      ehMinhaMensagem: ehMinhaMensagem,
                    );
                  },
                );
              },
            ),
          ),

          // Campo de entrada
          CampoMensagem(
            controller: _messageController,
            onEnviar: _sendMessage,
            onAnexar: _sendImage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
