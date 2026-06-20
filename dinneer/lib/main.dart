import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/tela_login.dart';
import 'theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyANMw8rbJBOC0wu2hgxY5QbuZjR4QOwx7w",
        appId: "1:832231555760:web:c01a009fe2f048bec7b175",
        messagingSenderId: "832231555760",
        projectId: "dinneer-19ada",
        storageBucket: "dinneer-19ada.firebasestorage.app",
        databaseURL: "https://dinneer-19ada-default-rtdb.firebaseio.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinneer',
      theme: AppTheme.light,
      home: const TelaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
