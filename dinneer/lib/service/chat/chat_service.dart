import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../models/message_model.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> sendMessage({
    required int encontroId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    try {
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
      rethrow;
    }
  }

  Stream<List<Message>> getMessages(int encontroId) {
    return _database
        .child('chats')
        .child(encontroId.toString())
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          final mensagens = <Message>[];

          try {
            if (event.snapshot.value != null) {
              final dadosMensagens = Map<dynamic, dynamic>.from(
                event.snapshot.value as Map,
              );

              dadosMensagens.forEach((chave, valor) {
                try {
                  mensagens.add(Message.fromJson(chave, valor));
                } catch (e) {
                  debugPrint('Erro ao parsear mensagem $chave: $e');
                }
              });

              mensagens.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            }
          } catch (e) {
            debugPrint(
              'Erro ao processar mensagens do encontro $encontroId: $e',
            );
          }

          return mensagens;
        });
  }

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

  Future<void> markAsRead(int encontroId, String userId) async {
    try {
      await _database
          .child('read_status')
          .child(encontroId.toString())
          .child(userId)
          .set(DateTime.now().millisecondsSinceEpoch);

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

  Future<void> sendEmote({
    required int encontroId,
    required String messageId,
    required String emote,
    required String senderId,
    required String senderName,
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
