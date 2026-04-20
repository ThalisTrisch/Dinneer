import 'package:flutter/foundation.dart';

/// Configuração centralizada da API
/// Permite alternar facilmente entre backends PHP e Node.js
class ApiConfig {
  // Toggle entre PHP (antigo) e Node.js (novo)
  // true = Node.js Backend (porta 3000)
  // false = PHP Backend (porta 80)
  static const bool useNodeBackend = true;
  
  /// Retorna a URL base de acordo com o backend selecionado
  static String get baseUrl {
    if (useNodeBackend) {
      // Node.js Backend (porta 3000)
      return kIsWeb 
        ? "http://localhost:3000/api/v1/"
        : "http://10.0.2.2:3000/api/v1/";
    } else {
      // PHP Backend (antigo)
      return kIsWeb 
        ? "http://localhost/pdm/api/v1/"
        : "http://10.0.2.2/pdm/api/v1/";
    }
  }
  
  /// Helper para remover .php dos endpoints quando usar Node.js
  static String getEndpoint(String controller) {
    if (useNodeBackend) {
      // Remove .php se estiver usando Node.js
      return controller.replaceAll('.php', '');
    }
    return controller;
  }
  
  /// Informações sobre o backend atual
  static String get backendInfo {
    return useNodeBackend 
      ? "Node.js Backend (TypeScript) - Port 3000"
      : "PHP Backend - Port 80";
  }
}
