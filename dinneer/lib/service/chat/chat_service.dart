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
  /// envia uma mensagem, todos os participantes recebem automaticamente
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
                  // Continua processando outras mensagens mesmo se uma falhar
                }
              });

              // Ordena por timestamp (mais recente primeiro) para exibir
              // as mensagens mais novas no topo da lista
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

      debugPrint('Mensagens marcadas como lidas para usuário $userId');
    } catch (e) {
      debugPrint('Erro ao marcar mensagens como lidas: $e');
      // Não repassa o erro porque marcar como lido é uma operação
      // secundária que não deve bloquear o fluxo principal
    }
  }
}
