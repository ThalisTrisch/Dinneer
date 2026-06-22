import 'package:flutter/foundation.dart';

class ApiConfig {
  static const bool useNodeBackend = true;

  static String get baseUrl {
    if (useNodeBackend) {
      return kIsWeb
          ? "http://localhost:3000/api/v1/"
          : "http://10.0.2.2:3000/api/v1/";
    } else {
      return kIsWeb
          ? "http://localhost/pdm/api/v1/"
          : "http://10.0.2.2/pdm/api/v1/";
    }
  }

  static String getEndpoint(String controller) {
    if (useNodeBackend) {
      return controller.replaceAll('.php', '');
    }
    return controller;
  }

  static String get backendInfo {
    return useNodeBackend
        ? "Node.js Backend (TypeScript) - Port 3000"
        : "PHP Backend - Port 80";
  }
}
