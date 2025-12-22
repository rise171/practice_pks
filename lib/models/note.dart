import 'package:flutter/foundation.dart'; // Добавляем для Key
import 'package:flutter/material.dart';

class Note {
  final int? id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  Note({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  // ОПТИМИЗАЦИЯ: Добавляем key для виджетов
  Key get key => id != null ? ValueKey<int>(id!) : ValueKey<String>('$title$body$createdAt');

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Note.fromMap(Map<String, Object?> map) {
    // ОПТИМИЗАЦИЯ: Оптимизированная десериализация
    final id = map['id'] as int?;
    final title = map['title'] as String? ?? '';
    final body = map['body'] as String? ?? '';

    // ОПТИМИЗАЦИЯ: Прямое преобразование без промежуточных переменных
    final createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int);
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int);

    // ОПТИМИЗАЦИЯ: Быстрая проверка boolean
    final isFavoriteInt = map['is_favorite'] as int? ?? 0;
    final isFavorite = isFavoriteInt == 1;

    return Note(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }
}