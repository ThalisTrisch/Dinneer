import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionService {
  static Future<void> salvarUsuarioId(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuarioId', usuarioId.toString());
  }

  static Future<String?> pegarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuarioId');
  }

  static Future<void> salvarUsuario(Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', jsonEncode(usuario));
  }

  static Future<Map<String, dynamic>> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');

    if (usuarioJson != null) {
      return Map<String, dynamic>.from(jsonDecode(usuarioJson));
    }

    return {};
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');
    await prefs.remove('usuario');
  }
}
