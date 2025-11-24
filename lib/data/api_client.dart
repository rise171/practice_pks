import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient({required String baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    //интерцепторы для ретраев и логирования
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) async {
        print('${error.type} ${error.message}');

        //Retry для сетевых ошибок
        if (_shouldRetry(error)) {
          final retryCount = error.requestOptions.extra['retry_count'] ?? 0;
          if (retryCount < 3) {
            final delay = Duration(milliseconds: 500 * (1 << retryCount));
            print('Retry $retryCount after ${delay.inMilliseconds}ms');

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
}