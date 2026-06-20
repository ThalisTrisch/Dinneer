import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:dinneer/models/message_model.dart';
import 'emote_button.dart';

class MessageBubble extends StatefulWidget {
  final Message mensagem;
  final bool ehMinhaMensagem;

  const MessageBubble({
    super.key,
    required this.mensagem,
    required this.ehMinhaMensagem,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _mostrarEmote = false;

  void _toggleEmote() {
    setState(() {
      _mostrarEmote = !_mostrarEmote;
    });
  }

  String _formatTime(DateTime timestamp) {
    final agora = DateTime.now();
    final diferenca = agora.difference(timestamp);

    if (diferenca.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
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
    final bool temImagem =
        widget.mensagem.imageUrl != null &&
        widget.mensagem.imageUrl!.isNotEmpty;
    final bool temTexto = widget.mensagem.text.isNotEmpty;

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
          if (widget.ehMinhaMensagem && _mostrarEmote)
            EmoteButton(onTap: () {}),

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
                  if (temImagem) ...[
                    GestureDetector(
                      onTap: () => _showImagePreview(widget.mensagem.imageUrl!),
                      child: kIsWeb
                          ? Image.network(
                              widget.mensagem.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
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
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 40,
                                    ),
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
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    if (temTexto) const SizedBox(height: 8),
                  ],
                  if (temTexto || !temImagem)
                    Padding(
                      padding: temImagem
                          ? const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              top: 8,
                              bottom: 4,
                            )
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
                  if (!widget.ehMinhaMensagem && temImagem && !temTexto)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 8,
                      ),
                      child: Text(
                        widget.mensagem.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  Padding(
                    padding: temImagem
                        ? const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 8,
                            top: 4,
                          )
                        : EdgeInsets.zero,
                    child: Text(
                      _formatTime(widget.mensagem.timestamp),
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

          if (!widget.ehMinhaMensagem && _mostrarEmote)
            EmoteButton(onTap: () {}),
        ],
      ),
    );
  }
}
