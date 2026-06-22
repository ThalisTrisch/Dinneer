import 'package:dinneer/service/http/HttpService.dart';
import 'package:dinneer/config/api_config.dart';

class UsuarioService {
  static final endpoint = ApiConfig.getEndpoint(
    "usuario/UsuarioController.php",
  );
  static final httpService = HttpService();

  UsuarioService();

  static Future<dynamic> getUsuarios() async {
    return await httpService.get(endpoint, "getUsuarios");
  }

  static Future<dynamic> login(String email, String senha) async {
    final body = {'vl_email': email, 'vl_senha': senha};
    return await httpService.post(endpoint, "loginUsuario", body: body);
  }

  static Future<dynamic> googleLogin(String email, String senha) async {
    final body = {'vl_email': email, 'vl_senha': senha};
    return await httpService.post(endpoint, "loginUsuario", body: body);
  }

  /// Verifica se um email já está cadastrado no sistema
  static Future<dynamic> verificarEmailExiste(String email) async {
    return await httpService.get(endpoint, "verificarEmailExiste", queryParams: {'vl_email': email});
  }

  /// Login OU cadastro via Google num passo só: o backend loga se o email
  /// existir, ou cria a conta a partir dos dados do Google se não existir.
  static Future<dynamic> loginOuCadastroGoogle({
    required String email,
    String? nome,
    String? sobrenome,
    String? foto,
  }) async {
    final body = {
      'vl_email': email,
      'nm_usuario': nome ?? '',
      'nm_sobrenome': sobrenome ?? '',
      'vl_foto': foto ?? '',
    };
    return await httpService.post(endpoint, "loginOuCadastroGoogle", body: body);
  }
 
  /// Busca os dados completos de um usuário pelo email
  static Future<dynamic> getUsuarioPorEmail(String email) async {
    return await httpService.get(endpoint, "getUsuarioPorEmail", queryParams: {'vl_email': email});
  }

  static Future<dynamic> createUsuario(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createUsuario", body: dados);
  }

  static Future<dynamic> atualizarFotoPerfil(
    dynamic idUsuario,
    String novaUrl,
  ) async {
    final body = {'id_usuario': idUsuario.toString(), 'vl_foto': novaUrl};
    return await httpService.post(endpoint, "atualizarFotoPerfil", body: body);
  }

  static Future<dynamic> atualizarFotoCapa(
    dynamic idUsuario,
    String novaUrl,
  ) async {
    final body = {'id_usuario': idUsuario.toString(), 'vl_foto_capa': novaUrl};
    return await httpService.post(endpoint, "atualizarFotoCapa", body: body);
  }
}
