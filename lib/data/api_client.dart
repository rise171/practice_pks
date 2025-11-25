import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient() {
    final baseUrl = dotenv.get('BASE_URL', fallback: 'https://jsonplaceholder.typicode.com');
    final timeout = int.tryParse(dotenv.get('API_TIMEOUT', fallback: '15')) ?? 15;

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: timeout),
      receiveTimeout: Duration(seconds: timeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final environment = dotenv.get('ENVIRONMENT', fallback: 'production');
        if (environment == 'development') {
          print('[${options.method}] ${options.uri}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Body: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final environment = dotenv.get('ENVIRONMENT', fallback: 'production');
        if (environment == 'development') {
          print('[${response.statusCode}] ${response.requestOptions.uri}');
          print('Response: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        final environment = dotenv.get('ENVIRONMENT', fallback: 'production');
        if (environment == 'development') {
          print('[${error.type}] ${error.message}');
          if (error.response != null) {
            print('Error Response: ${error.response?.data}');
          }
        }

        // Ретраи для сетевых ошибок (экспоненциальная пауза)
        if (_shouldRetry(error)) {
          final retryCount = error.requestOptions.extra['retry_count'] ?? 0;
          if (retryCount < 3) {
            final delay = Duration(milliseconds: 500 * (1 << retryCount));

            if (environment == 'development') {
              print('Retry $retryCount after ${delay.inMilliseconds}ms');
            }

            await Future.delayed(delay);

            error.requestOptions.extra['retry_count'] = retryCount + 1;
            try {
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (retryError) {
              handler.next(error);
              return;
            }
          }
        }

        handler.next(error);
      },
    ));

    return ApiClient._(dio);
  }

  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  //Геттер для базового URL
  String get baseUrl => dio.options.baseUrl;
  // Геттер для текущего окружения
  String get environment => dotenv.get('ENVIRONMENT', fallback: 'production');
}