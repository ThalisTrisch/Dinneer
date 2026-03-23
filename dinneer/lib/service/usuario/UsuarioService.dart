import 'package:dinneer/service/http/HttpService.dart';

class UsuarioService {
  static const endpoint = "usuario/UsuarioController.php";
  static final httpService = HttpService(); 

  UsuarioService();

  static Future<dynamic> getUsuarios() async {
    return await httpService.get(endpoint, "getUsuarios");
  }

   static Future<dynamic> login(String email, String senha) async {
    final body = {
      'vl_email': email,
      'vl_senha': senha,
    };
    return await httpService.post(endpoint, "loginUsuario", body: body);
  }

  static Future<dynamic> createUsuario(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createUsuario", body: dados);
  }

  static Future<dynamic> atualizarFotoPerfil(dynamic idUsuario, String novaUrl) async {
    final body = {
      'id_usuario': idUsuario.toString(),
      'vl_foto': novaUrl,
    };
    return await httpService.post(endpoint, "atualizarFotoPerfil", body: body);
  }
}