import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../sessao/SessionService.dart';

class HttpService {
  String get baseUrl => ApiConfig.baseUrl;

  HttpService();

  Future<Map<String, String>> _montarHeaders([
    Map<String, String>? extras,
  ]) async {
    final headers = <String, String>{if (extras != null) ...extras};
    final token = await SessionService.pegarToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> post(
    String endpoint,
    String operacao, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint?operacao=$operacao");

    try {
      final response = await http.post(
        url,
        headers: await _montarHeaders({
          "Content-Type": "application/x-www-form-urlencoded",
        }),
        body: body,
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Erro na API: ${response.statusCode}. Resposta: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<dynamic> get(
    String endpoint,
    String operacao, {
    Map<String, dynamic>? queryParams,
  }) async {
    final Map<String, dynamic> params = {
      "operacao": operacao,
      if (queryParams != null) ...queryParams,
    };

    final url = Uri.parse(baseUrl + endpoint).replace(queryParameters: params);

    try {
      final response = await http.get(url, headers: await _montarHeaders());

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
