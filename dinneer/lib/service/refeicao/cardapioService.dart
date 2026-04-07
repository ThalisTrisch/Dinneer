import '../http/HttpService.dart';
import '../../config/api_config.dart';

class CardapioService {
  static final endpoint = ApiConfig.getEndpoint("cardapio/CardapioController.php");
  static final httpService = HttpService();

  static Future<dynamic> createJantar(Map<String, dynamic> dados) async {
    // Node.js backend usa "createJantarCompleto" ao invés de "createJantar"
    final operacao = ApiConfig.useNodeBackend ? "createJantarCompleto" : "createJantar";
    return await httpService.post(endpoint, operacao, body: dados);
  }

  static Future<dynamic> getCardapiosDisponiveis() async {
    final resposta = await httpService.get(endpoint, "getCardapiosDisponiveis");
    print("DEBUG HOME: $resposta"); 
    return resposta;
  }

  static Future<dynamic> updateJantar(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "updateJantar", body: dados);
  }

  static Future<dynamic> getMeuCardapio(int idLocal) async {
    return await httpService.get(
      endpoint, 
      "getMeuCardapio",       
      queryParams: {
        "id_local": idLocal.toString(),
      }
    );
  }

  static Future<dynamic> deleteJantar(int idJantar) async {
    // Node.js backend usa "deleteJantar" ao invés de "deleteCardapio"
    final operacao = ApiConfig.useNodeBackend ? "deleteJantar" : "deleteCardapio";
    return await httpService.post(
      endpoint,
      operacao,
      body: {
        "id_cardapio": idJantar.toString(),
      },
    );
  }
}
