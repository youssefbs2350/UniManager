import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Configuration de connexion au Backend Spring Boot + MongoDB
class ApiConfig {
  /// Mettre à true pour consommer le backend Spring Boot en direct
  static const bool useOnlineBackend = true;

  /// Port du serveur Spring Boot (8081 pour éviter le conflit avec Oracle sur 8080)
  static const int port = 8081;

  /// URL de base adaptée automatiquement à la plateforme :
  /// - Émulateur Android : 10.0.2.2
  /// - Web / Windows / iOS : localhost
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port/api';
    }
    return 'http://localhost:$port/api';
  }

  static String get studentsEndpoint => '$baseUrl/students';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
