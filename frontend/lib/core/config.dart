// lib/core/config.dart
class Config {
  static const bool useLocal = true;
  static const String apiBaseUrl =
      useLocal ? "http://127.0.0.1:8000" : "https://your-prod-api.example.com";
}
