import 'package:flutter/foundation.dart';
import '../http/HttpService.dart';
import '../../config/api_config.dart';

class AvaliacaoService {
  static final endpoint = ApiConfig.getEndpoint(
    "avaliacao/AvaliacaoController.php",
  );
  static final httpService = HttpService();

  static Future<dynamic> avaliar(
    int idUsuario,
    int idEncontro,
    int idTipoAvaliacao,
    double nota,
  ) async {
    return await httpService.post(
      endpoint,
      "createAvaliacao",
      body: {
        "id_usuario": idUsuario.toString(),
        "id_encontro": idEncontro.toString(),
        "id_avaliacao": idTipoAvaliacao.toString(),
        "vl_avaliacao": nota.toInt().toString(),
      },
    );
  }

  static Future<Map<String, dynamic>> getMediaUsuario(int idUsuario) async {
    debugPrint(
      "--- AVALIACAO: Buscando média para o usuário ID $idUsuario ---",
    );
    try {
      final resposta = await httpService.get(
        endpoint,
        "getMediaUsuario",
        queryParams: {"id_usuario": idUsuario.toString()},
      );

      debugPrint("--- AVALIACAO: Resposta do servidor: $resposta ---");

      if (resposta != null && resposta['dados'] != null) {
        final dados = (resposta['dados'] is List)
            ? (resposta['dados'] as List).first
            : resposta['dados'];

        return {
          "media": double.tryParse(dados['media'].toString()) ?? 0.0,
          "total": int.tryParse(dados['total'].toString()) ?? 0,
        };
      }
      return {"media": 0.0, "total": 0};
    } catch (e) {
      debugPrint("--- AVALIACAO: Erro ao buscar média: $e ---");
      return {"media": 0.0, "total": 0};
    }
  }

  static Future<List<Map<String, dynamic>>> getAvaliacoesPorDia(
    int idUsuario,
  ) async {
    debugPrint(
      "--- AVALIACAO: Buscando avaliacoes por dia para o usuario ID $idUsuario ---",
    );
    try {
      final resposta = await httpService.get(
        endpoint,
        "getAvaliacoesPorDia",
        queryParams: {"id_usuario": idUsuario.toString()},
      );

      if (resposta != null && resposta['dados'] is List) {
        return (resposta['dados'] as List).map<Map<String, dynamic>>((item) {
          final encontros = item['encontros'] is List
              ? (item['encontros'] as List).map<Map<String, dynamic>>((
                  encontro,
                ) {
                  return {
                    "id_encontro":
                        int.tryParse(encontro['id_encontro'].toString()) ?? 0,
                    "hora": encontro['hora']?.toString() ?? '',
                    "media":
                        double.tryParse(encontro['media'].toString()) ?? 0.0,
                    "total": int.tryParse(encontro['total'].toString()) ?? 0,
                  };
                }).toList()
              : <Map<String, dynamic>>[];

          return {
            "data": item['data']?.toString() ?? '',
            "media": double.tryParse(item['media'].toString()) ?? 0.0,
            "total": int.tryParse(item['total'].toString()) ?? 0,
            "encontros": encontros,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("--- AVALIACAO: Erro ao buscar avaliacoes por dia: $e ---");
      return [];
    }
  }
}
