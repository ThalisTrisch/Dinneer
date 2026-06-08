import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../models/message_model.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Envia uma mensagem para um encontro específico
  ///
  /// Valida o texto antes de enviar para evitar mensagens vazias
  /// que causariam problemas na UI e desperdiçariam espaço no Firebase
  Future<void> sendMessage({
    required int encontroId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    try {
      // Validação: não permite mensagens vazias
      if (text.trim().isEmpty && imageUrl == null) {
        throw Exception('Mensagem não pode estar vazia');
      }

      final messageRef = _database
          .child('chats')
          .child(encontroId.toString())
          .push();

      final message = Message(
        id: messageRef.key!,
        senderId: senderId,
        senderName: senderName,
        text: text.trim(),
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      await messageRef.set(message.toJson());

      debugPrint('Mensagem enviada com sucesso para encontro $encontroId');
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
      rethrow; // Repassa o erro para a UI tratar
    }
  }

  /// Retorna um Stream de mensagens de um encontro
  ///
  /// Usa Stream para atualização em tempo real - quando qualquer usuário
  /// envia uma mensagem, todos os participantes recebem automaticamente.
  /// Os emotes de cada mensagem são associados pelo messageId.
  Stream<List<Message>> getMessages(int encontroId) {
    return _database
        .child('chats')
        .child(encontroId.toString())
        .onValue
        .map((event) {
          final mensagens = <Message>[];

          try {
            if (event.snapshot.value != null) {
              final dadosChat = Map<dynamic, dynamic>.from(
                event.snapshot.value as Map,
              );

              // Extrai os emotes do nó separado e agrupa por messageId
              final Map<String, List<String>> emotesPorMensagem = {};
              if (dadosChat.containsKey('emotes')) {
                final dadosEmotes = Map<dynamic, dynamic>.from(dadosChat['emotes']);
                dadosEmotes.forEach((chave, valor) {
                  final emoteData = Map<dynamic, dynamic>.from(valor);
                  final msgId = emoteData['messageId']?.toString() ?? '';
                  final emote = emoteData['emote']?.toString() ?? '';
                  if (msgId.isNotEmpty && emote.isNotEmpty) {
                    emotesPorMensagem.putIfAbsent(msgId, () => []).add(emote);
                  }
                });
              }

              // Processa as mensagens ignorando o nó 'emotes'
              dadosChat.forEach((chave, valor) {
                if (chave == 'emotes') return; // pula o nó de emotes
                try {
                  final emotesDaMensagem = emotesPorMensagem[chave.toString()] ?? [];
                  mensagens.add(Message.fromJson(chave, valor, emotes: emotesDaMensagem));
                } catch (e) {
                  debugPrint('Erro ao parsear mensagem $chave: $e');
                }
              });

              mensagens.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            }
          } catch (e) {
            debugPrint('Erro ao processar mensagens do encontro $encontroId: $e');
          }

          return mensagens;
        });
  }

  /// Deleta uma mensagem específica
  ///
  /// Usado quando o usuário quer remover uma mensagem enviada por engano
  Future<void> deleteMessage(int encontroId, String messageId) async {
    try {
      await _database
          .child('chats')
          .child(encontroId.toString())
          .child(messageId)
          .remove();

      debugPrint('Mensagem $messageId deletada do encontro $encontroId');
    } catch (e) {
      debugPrint('Erro ao deletar mensagem: $e');
      rethrow;
    }
  }

  /// Marca mensagens como lidas por um usuário
  ///
  /// Usado para implementar indicadores de "lido" e badges de mensagens
  /// não lidas (funcionalidade futura)
  Future<void> markAsRead(int encontroId, String userId) async {
    try {
      await _database
          .child('read_status')
          .child(encontroId.toString())
          .child(userId)
          .set(DateTime.now().millisecondsSinceEpoch);

      // Reset notification counter so the next messages trigger FCM again
      await _database
          .child('unread_counts')
          .child(encontroId.toString())
          .child(userId)
          .set(0);

      debugPrint('Mensagens marcadas como lidas para usuário $userId');
    } catch (e) {
      debugPrint('Erro ao marcar mensagens como lidas: $e');
    }
  }

  /// Envia um emote em resposta a uma mensagem de outro usuário
  ///
  /// O emote é salvo dentro do nó chats/{encontroId}/emotes/
  /// com uma chave gerada automaticamente pelo Firebase
  Future<void> sendEmote({
    required int encontroId,
    required String emote,
    required String senderId,
    required String senderName,
    required String messageId,
  }) async {
    try {
      final emoteRef = _database
          .child('chats')
          .child(encontroId.toString())
          .child('emotes')
          .push();

      await emoteRef.set({
        'messageId': messageId,
        'emote': emote,
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('Emote "$emote" enviado com sucesso para mensagem $messageId');
    } catch (e) {
      debugPrint('Erro ao enviar emote: $e');
      rethrow;
    }
  }
}
