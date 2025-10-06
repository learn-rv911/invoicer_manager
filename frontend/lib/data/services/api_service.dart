import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice/core/config.dart';

class ApiService {
  final Dio dio;

  ApiService._internal(this.dio);

  factory ApiService() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) => handler.next(error),
      ),
    );

    return ApiService._internal(dio);
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
