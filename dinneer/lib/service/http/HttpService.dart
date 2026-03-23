import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HttpService {

  // Use localhost for web, 10.0.2.2 for Android emulator
  String baseUrl = kIsWeb 
    ? "http://localhost/pdm/api/v1/" 
    : "http://10.0.2.2/pdm/api/v1/";

  HttpService();

  Future<dynamic> post(String endpoint, String operacao, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint?operacao=$operacao");

    debugPrint("--------------------");
    debugPrint("POST Request URL: $url");
    debugPrint("Request Body: $body");

    try {

      print(body);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
        encoding: Encoding.getByName('utf-8'),
      );
      
      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      debugPrint("--------------------");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro na API: ${response.statusCode}. Resposta: ${response.body}');
      }
    } catch (e) {
      debugPrint("Falha na requisição: $e");
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

    final url = Uri.parse(baseUrl + endpoint).replace(
      queryParameters: params,
    );

    try {
      final response = await http.get(url);

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
