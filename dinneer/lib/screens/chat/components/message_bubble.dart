import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:dinneer/models/message_model.dart';
import 'package:dinneer/service/chat/chat_service.dart';
import 'emote_button.dart';

/// Balão de uma mensagem do chat (texto e/ou imagem).
///
/// É StatefulWidget para controlar, de forma independente por mensagem,
/// a visibilidade do botão de emote ao tocar em mensagens de outros usuários.
class MessageBubble extends StatefulWidget {
  final Message mensagem;
  final bool ehMinhaMensagem;
  final String? userId;
  final String? userName;
  final int encontroId;

  const MessageBubble({
    super.key,
    required this.mensagem,
    required this.ehMinhaMensagem,
    required this.encontroId,
    this.userId,
    this.userName,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _mostrarEmote = false;
  final ChatService _chatService = ChatService();

  void _toggleEmote() {
    setState(() => _mostrarEmote = !_mostrarEmote);
  }

  String _formatTime(DateTime timestamp) {
    final agora = DateTime.now();
    final diferenca = agora.difference(timestamp);
    if (diferenca.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
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
              child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
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

  void _showEmotePicker(BuildContext context) {
    const emojis = ['❤️', '😂', '😮', '👏'];

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => GestureDetector(
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmojiItem(context, emojis[0]),
                          const SizedBox(width: 4),
                          _buildEmojiItem(context, emojis[1]),
                        ],
                      ),
                      const SizedBox(height: 4),
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

  Widget _buildEmojiItem(BuildContext context, String emoji) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();
        setState(() => _mostrarEmote = false);
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

  @override
  Widget build(BuildContext context) {
    final bool temImagem =
        widget.mensagem.imageUrl != null &&
        widget.mensagem.imageUrl!.isNotEmpty;
    final bool temTexto = widget.mensagem.text.isNotEmpty;
    final bool temEmotes = widget.mensagem.emotes.isNotEmpty;

    return Align(
      alignment: widget.ehMinhaMensagem
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: widget.ehMinhaMensagem
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Indicador de emotes à esquerda (minhas mensagens)
          if (widget.ehMinhaMensagem && temEmotes)
            _EmoteIndicator(emotes: widget.mensagem.emotes),

          // Botão para abrir o picker (minhas mensagens — lado esquerdo)
          if (widget.ehMinhaMensagem && _mostrarEmote)
            EmoteButton(onTap: () => _showEmotePicker(context)),

          // Balão da mensagem
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
                  bottomLeft: Radius.circular(widget.ehMinhaMensagem ? 16 : 0),
                  bottomRight: Radius.circular(widget.ehMinhaMensagem ? 0 : 16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagem
                  if (temImagem) ...[
                    GestureDetector(
                      onTap: () => _showImagePreview(widget.mensagem.imageUrl!),
                      child: kIsWeb
                          ? Image.network(
                              widget.mensagem.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, _) => Container(
                                height: 100,
                                color: Colors.grey[400],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white, size: 40),
                                ),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.mensagem.imageUrl!,
                              fit: BoxFit.cover,
                              httpHeaders: const {'Accept': 'image/*'},
                              placeholder: (context, url) => Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 100,
                                color: Colors.grey[400],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white, size: 40),
                                ),
                              ),
                            ),
                    ),
                    if (temTexto) const SizedBox(height: 8),
                  ],
                  // Texto
                  if (temTexto || !temImagem)
                    Padding(
                      padding: temImagem
                          ? const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4)
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
                              color: widget.ehMinhaMensagem ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Nome do remetente em mensagens só de imagem
                  if (!widget.ehMinhaMensagem && temImagem && !temTexto)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
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
                        ? const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4)
                        : EdgeInsets.zero,
                    child: Text(
                      _formatTime(widget.mensagem.timestamp),
                      style: TextStyle(
                        color: widget.ehMinhaMensagem ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão para abrir o picker (mensagens de outros — lado direito)
          if (!widget.ehMinhaMensagem && _mostrarEmote)
            EmoteButton(onTap: () => _showEmotePicker(context)),

          // Indicador de emotes à direita (mensagens de outros)
          if (!widget.ehMinhaMensagem && temEmotes)
            _EmoteIndicator(emotes: widget.mensagem.emotes),
        ],
      ),
    );
  }
}

/// Exibe os emojis recebidos agrupados com contagem.
class _EmoteIndicator extends StatelessWidget {
  final List<String> emotes;

  const _EmoteIndicator({required this.emotes});

  @override
  Widget build(BuildContext context) {
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
