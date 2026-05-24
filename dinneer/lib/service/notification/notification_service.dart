import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _chatChannel = AndroidNotificationChannel(
  'chat_notifications',
  'Mensagens de Chat',
  description: 'Notificações de novas mensagens no chat',
  importance: Importance.high,
);

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize(String userId) async {
    // ⚠️ Push notifications are NOT supported on web
    // Skip initialization to avoid service worker errors
    if (kIsWeb) {
      debugPrint('⚠️ Push notifications não são suportadas na web. Pulando inicialização.');
      return;
    }

    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // Create the Android notification channel before registering
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_chatChannel);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      final token = await _messaging.getToken();
      if (token != null) await _saveToken(userId, token);

      _messaging.onTokenRefresh.listen((newToken) => _saveToken(userId, newToken));

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      debugPrint('✅ Notificações push inicializadas com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar notificações: $e');
      // Não propaga o erro para não quebrar o login
    }
  }

  static Future<void> _saveToken(String userId, String token) async {
    try {
      await FirebaseDatabase.instance.ref('users/$userId/fcmToken').set(token);
      debugPrint('FCM token salvo para usuário $userId');
    } catch (e) {
      debugPrint('Erro ao salvar FCM token: $e');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chatChannel.id,
          _chatChannel.name,
          channelDescription: _chatChannel.description,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> sendChatNotification({
    required int encontroId,
    required String senderId,
    required String senderName,
    required String messageText,
  }) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}notification/send-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_encontro': encontroId,
          'id_usuario': senderId,
          'nm_usuario': senderName,
          'tx_mensagem': messageText,
        }),
      );
    } catch (e) {
      debugPrint('Notificação falhou (não bloqueante): $e');
    }
  }
}
