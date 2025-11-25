import 'package:dio/dio.dart';
import '../models/note.dart';
import 'api_client.dart';

class NotesRepository {
  final ApiClient _client;

  NotesRepository() : _client = ApiClient();

  Future<List<Note>> list({int page = 1, int limit = 20, String? searchQuery}) async {
    try {
      final queryParameters = {
        '_page': page,
        '_limit': limit,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'title_like': searchQuery,
      };

      final response = await _client.dio.get(
        '/posts',
        queryParameters: queryParameters,
      );

      final data = response.data as List<dynamic>;
      return data.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Note> get(int id) async {
    try {
      final response = await _client.dio.get('/posts/$id');
      return Note.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Note> create(String title, String body) async {
    try {
      final response = await _client.dio.post(
        '/posts',
        data: {
          'title': title,
          'body': body,
          'userId': 1,
        },
      );
      return Note.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Note> update(int id, String title, String body) async {
    try {
      final response = await _client.dio.patch(
        '/posts/$id',
        data: {
          'title': title,
          'body': body,
        },
      );
      return Note.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.dio.delete('/posts/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Таймаут соединения. Проверьте интернет.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('Нет соединения с интернетом.');
    } else if (e.response?.statusCode != null) {
      return Exception('Ошибка сервера: ${e.response?.statusCode}');
    } else {
      return Exception('Неизвестная ошибка: ${e.message}');
    }
  }
}
