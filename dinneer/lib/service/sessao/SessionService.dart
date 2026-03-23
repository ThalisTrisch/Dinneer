
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> salvarUsuarioId(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuarioId', usuarioId.toString());
  }

  static Future<String?> pegarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuarioId');
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');
  }
}
