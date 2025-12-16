import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqlite_app/page/note_page.dart';

// Глобальный логгер ошибок
class ErrorLogger {
  static void logError(dynamic error, StackTrace stackTrace, {String? context}) {
    if (kDebugMode) {
      print('ERROR ${context != null ? '[$context]' : ''}: $error');
      print('STACK TRACE:');
      print(stackTrace);
    }
  }
  static void logFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      print('FLUTTER ERROR: ${details.exception}');
      print('LIBRARY: ${details.library}');
      print('STACK: ${details.stack}');
    }
  }
}

//виджет для отображения ошибок
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка ошибки
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              // Заголовок
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Сообщение
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Детали ошибки (только в debug режиме)
              if (kDebugMode && error != null)
                _buildErrorDetails(context),

              const SizedBox(height: 32),

              // Кнопка действия
              if (onRetry != null)
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                  ),
                  child: const Text('Повторить попытку'),
                ),

              const SizedBox(height: 16),

              // Кнопка возврата
              if (Navigator.of(context).canPop())
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Вернуться назад'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDetails(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Детали ошибки (только для разработки)',
        style: TextStyle(fontSize: 14),
      ),
      initiallyExpanded: false,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                error.toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
              if (stackTrace != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Stack trace:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText(
                  stackTrace.toString(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

//ErrorWidget для Flutter ошибок
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorWidget({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    ErrorLogger.logFlutterError(errorDetails);

    return ErrorScreen(
      title: 'Ошибка в интерфейсе',
      message: 'Произошла ошибка при отображении интерфейса. '
          'Попробуйте перезагрузить приложение или вернуться назад.',
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
      onRetry: () {
        runApp(const NotesApp());
      },
    );
  }
}

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    // Настройка глобальных обработчиков ошибок Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      // Показываем стандартное сообщение об ошибке
      FlutterError.presentError(details);
      // Логируем ошибку
      ErrorLogger.logFlutterError(details);
    };

    // Устанавливаем кастомный виджет для ошибок Flutter
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return CustomErrorWidget(errorDetails: errorDetails);
    };
    // Запускаем приложение
    runApp(const NotesApp());
  }, (Object error, StackTrace stackTrace) {
    // Обработка непойманных ошибок Dart (вне Flutter)
    ErrorLogger.logError(error, stackTrace, context: 'UNCAUGHT DART ERROR');
    if (kDebugMode) {
      print('Необработанная ошибка Dart, требуется перезапуск приложения');
    }
  });
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes SQLite',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      home: const NotesPage(),
      debugShowCheckedModeBanner: false,

      // Глобальный обработчик ошибок навигации
      builder: (BuildContext context, Widget? widget) {
        Widget result = widget ?? const SizedBox();

        // Добавляем обработчик ошибок для всего приложения
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomErrorWidget(errorDetails: errorDetails);
        };

        return result;
      },

      // Обработчик ошибок маршрутизации
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            // Если маршрут не найден
            if (settings.name != '/') {
              return ErrorScreen(
                title: 'Страница не найдена',
                message: 'Запрошенная страница "${settings.name}" не существует.',
                onRetry: () => Navigator.of(context).pop(),
              );
            }
            return const NotesPage();
          },
        );
      },
    );
  }
}