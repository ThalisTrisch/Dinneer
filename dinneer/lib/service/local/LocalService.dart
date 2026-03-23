import 'package:flutter/foundation.dart';
import '../http/HttpService.dart';

class LocalService {
  static const endpoint = "local/LocalController.php";
  static final httpService = HttpService();

  static Future<dynamic> getMeusLocais(String idUsuario) async {
    debugPrint("LocalService: Buscando locais para o ID $idUsuario...");

    return await httpService.get(
      endpoint, 
      "getMeusLocais", 
      queryParams: {
        "id_usuario": idUsuario,
      }
    );
  }

  static Future<dynamic> createLocal(Map<String, dynamic> dados) async {
    debugPrint("LocalService: Criando local com dados: $dados");
    return await httpService.post(endpoint, "createLocal", body: dados);
  }

  static Future<dynamic> deleteLocal(String idLocal) async {
    debugPrint("LocalService: Deletando local ID $idLocal...");
    final body = {'id_local': idLocal};
    return await httpService.post(endpoint, "deleteLocal", body: body);
  }
}