import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../service/chat/chat_service.dart';
import '../service/sessao/SessionService.dart';

class TelaChat extends StatefulWidget {
  final int encontroId;
  final String encontroNome;

  const TelaChat({
    super.key,
    required this.encontroId,
    required this.encontroNome,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dadosUsuario = await SessionService.getUsuario();

      if (mounted) {
        setState(() {
          _userId = dadosUsuario['id_usuario']?.toString();
          _userName = dadosUsuario['nm_usuario'] ?? 'Usuário';
        });
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

      // Scroll para o final após enviar mensagem
      // Delay necessário para aguardar a mensagem ser adicionada à lista
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
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

                    return _buildMessageBubble(mensagem, ehMinhaMensagem);
                  },
                );
              },
            ),
          ),

          // Campo de entrada
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message mensagem, bool ehMinhaMensagem) {
    return Align(
      alignment: ehMinhaMensagem ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: ehMinhaMensagem ? Colors.grey[800] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(ehMinhaMensagem ? 16 : 0),
            bottomRight: Radius.circular(ehMinhaMensagem ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostra o nome do remetente apenas para mensagens de outros usuários
            if (!ehMinhaMensagem)
              Text(
                mensagem.senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            if (!ehMinhaMensagem) const SizedBox(height: 4),
            Text(
              mensagem.text,
              style: TextStyle(
                color: ehMinhaMensagem ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(mensagem.timestamp),
              style: TextStyle(
                color: ehMinhaMensagem ? Colors.white70 : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formata o timestamp da mensagem de forma amigável
  ///
  /// Se for hoje, mostra apenas a hora
  /// Se for outro dia, mostra data + hora
  String _formatTime(DateTime timestamp) {
    final agora = DateTime.now();
    final diferenca = agora.difference(timestamp);

    if (diferenca.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
