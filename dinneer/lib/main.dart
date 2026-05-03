import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart'; // Importante
import 'screens/tela_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper configuration
  if (kIsWeb) {
    // For web platform
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyANMw8rbJBOC0wu2hgxY5QbuZjR4QOwx7w",
        appId: "1:832231555760:web:c01a009fe2f048bec7b175",
        messagingSenderId: "832231555760",
        projectId: "dinneer-19ada",
        storageBucket: "dinneer-19ada.firebasestorage.app",
      ),
    );
  } else {
    // For mobile platforms (uses google-services.json / GoogleService-Info.plist)
    await Firebase.initializeApp();
  }

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinneer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TelaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
