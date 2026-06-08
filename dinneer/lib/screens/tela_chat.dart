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
                      formatTime: _formatTime,
                      userId: _userId,
                      userName: _userName,
                      encontroId: widget.encontroId,
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

// Widget separado para cada balão de mensagem.
// Precisa ser StatefulWidget para gerenciar o estado de visibilidade
// do botão de emote de forma independente por mensagem.
class _MessageBubble extends StatefulWidget {
  final Message mensagem;
  final bool ehMinhaMensagem;
  final String Function(DateTime) formatTime;
  final String? userId;
  final String? userName;
  final int encontroId;

  const _MessageBubble({
    required this.mensagem,
    required this.ehMinhaMensagem,
    required this.formatTime,
    required this.userId,
    required this.userName,
    required this.encontroId,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  // Controla se o botão de emote está visível para esta mensagem
  bool _mostrarEmote = false;
  final ChatService _chatService = ChatService();

  void _toggleEmote() {
    setState(() {
      _mostrarEmote = !_mostrarEmote;
    });
  }

  /// Exibe o balão de seleção de emojis próximo ao botão de emote
  void _showEmotePicker(BuildContext context) {
    // Lista dos 4 emojis disponíveis: 2 na linha de cima, 2 na de baixo
    const emojis = ['❤️', '😂', '😮', '👏'];

    showDialog(
      context: context,
      barrierColor: Colors.transparent, // fundo transparente para parecer um balão flutuante
      builder: (context) => GestureDetector(
        // Fecha ao tocar fora do balão
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: widget.ehMinhaMensagem
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                right: widget.ehMinhaMensagem ? 60 : 0,
                left: widget.ehMinhaMensagem ? 0 : 60,
              ),
              child: GestureDetector(
                // Impede que o toque no balão feche o dialog
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Linha de cima: 2 emojis
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmojiItem(context, emojis[0]),
                          const SizedBox(width: 4),
                          _buildEmojiItem(context, emojis[1]),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Linha de baixo: 2 emojis
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmojiItem(context, emojis[2]),
                          const SizedBox(width: 4),
                          _buildEmojiItem(context, emojis[3]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói cada emoji clicável dentro do balão
  Widget _buildEmojiItem(BuildContext context, String emoji) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop(); // fecha o picker
        setState(() => _mostrarEmote = false); // esconde o botão de emote

        try {
          await _chatService.sendEmote(
            encontroId: widget.encontroId,
            messageId: widget.mensagem.id,
            emote: emoji,
            senderId: widget.userId ?? '',
            senderName: widget.userName ?? 'Usuário',
          );
        } catch (e) {
          debugPrint('Erro ao enviar emote: $e');
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100],
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool temImagem = widget.mensagem.imageUrl != null &&
        widget.mensagem.imageUrl!.isNotEmpty;
    final bool temTexto = widget.mensagem.text.isNotEmpty;

    return Align(
      alignment: widget.ehMinhaMensagem
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        // Balões próprios ficam à direita, então o emote fica antes (esquerda)
        // Balões de outros ficam à esquerda, então o emote fica depois (direita)
        mainAxisAlignment: widget.ehMinhaMensagem
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Indicador fixo de emotes — aparece à esquerda das minhas mensagens
          if (widget.ehMinhaMensagem && widget.mensagem.emotes.isNotEmpty)
            _EmoteIndicator(emotes: widget.mensagem.emotes),

          // Botão de emote à esquerda (apenas para mensagens próprias)
          if (widget.ehMinhaMensagem && _mostrarEmote)
            _EmoteButton(onTap: () => _showEmotePicker(context)),

          // Balão da mensagem — GestureDetector captura o toque
          GestureDetector(
            onTap: !widget.ehMinhaMensagem ? _toggleEmote : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: temImagem
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: widget.ehMinhaMensagem
                    ? Colors.grey[800]
                    : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(widget.ehMinhaMensagem ? 16 : 0),
                  bottomRight:
                      Radius.circular(widget.ehMinhaMensagem ? 0 : 16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagem (se houver)
                  if (temImagem) ...[
                    GestureDetector(
                      onTap: () => _showImagePreview(widget.mensagem.imageUrl!),
                      child: kIsWeb
                          ? Image.network(
                              widget.mensagem.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: Colors.grey[400],
                                  child: const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.white, size: 40),
                                  ),
                                );
                              },
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.mensagem.imageUrl!,
                              fit: BoxFit.cover,
                              httpHeaders: const {'Accept': 'image/*'},
                              placeholder: (context, url) => Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 100,
                                color: Colors.grey[400],
                                child: const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.white, size: 40),
                                ),
                              ),
                            ),
                    ),
                    if (temTexto) const SizedBox(height: 8),
                  ],
                  // Conteúdo de texto
                  if (temTexto || !temImagem)
                    Padding(
                      padding: temImagem
                          ? const EdgeInsets.only(
                              left: 12, right: 12, top: 8, bottom: 4)
                          : EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!widget.ehMinhaMensagem) ...[
                            Text(
                              widget.mensagem.senderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            widget.mensagem.text,
                            style: TextStyle(
                              color: widget.ehMinhaMensagem
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Nome do remetente para mensagens só de imagem
                  if (!widget.ehMinhaMensagem && temImagem && !temTexto)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 8),
                      child: Text(
                        widget.mensagem.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  // Timestamp
                  Padding(
                    padding: temImagem
                        ? const EdgeInsets.only(
                            left: 12, right: 12, bottom: 8, top: 4)
                        : EdgeInsets.zero,
                    child: Text(
                      widget.formatTime(widget.mensagem.timestamp),
                      style: TextStyle(
                        color: widget.ehMinhaMensagem
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de emote à direita (apenas para mensagens de outros)
          if (!widget.ehMinhaMensagem && _mostrarEmote)
            _EmoteButton(onTap: () => _showEmotePicker(context)),

          // Indicador fixo de emotes — aparece à direita das mensagens de outros
          if (!widget.ehMinhaMensagem && widget.mensagem.emotes.isNotEmpty)
            _EmoteIndicator(emotes: widget.mensagem.emotes),
        ],
      ),
    );
  }
}

// Botão de emote reutilizável
class _EmoteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EmoteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text('😶', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

/// Indicador fixo que exibe os emotes recebidos em uma mensagem.
/// Aparece à esquerda das minhas mensagens e à direita das mensagens de outros.
class _EmoteIndicator extends StatelessWidget {
  final List<String> emotes;

  const _EmoteIndicator({required this.emotes});

  @override
  Widget build(BuildContext context) {
    // Agrupa emotes iguais e conta quantos de cada
    final Map<String, int> contagem = {};
    for (final emote in emotes) {
      contagem[emote] = (contagem[emote] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: contagem.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 14)),
                  if (entry.value > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
