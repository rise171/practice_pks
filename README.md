### Практическая работа 8. Петрова Кристина ЭФБО-06-23. Без аутентификации

1. Скриншот настроенного проекта Firebase:
![img_1.png](img_1.png)
2. Отображение списка:
![img_6.png](img_6.png)
3. После добавления заметки:
   ![img_2.png](img_2.png)
   ![img_8.png](img_8.png)
4. После редактирования заметки:
   ![img_3.png](img_3.png)
   ![img_4.png](img_4.png)
   ![img_9.png](img_9.png)
5. После удаления заметки:
![img_7.png](img_7.png)
6. Краткий отчет:
   - Проект на Firebase создавался через Firebase CLI.
     Процесс настройки:
     - Установка FlutterFire CLI: dart pub global activate flutterfire_cli 
     - Авторизация в Google: flutterfire configure 
     - Создан новый Firebase проект: mu-flutter-app-notes 
     - Подключены платформы: Android, iOS, Web, Windows 
     - Автоматически сгенерирован файл lib/firebase_options.dart
   - Использовались такие пакеты как   firebase_core: ^3.15.2, cloud_firestore: ^5.4.4, firebase_auth: ^5.3.0 в pubspec.yaml. Инициализация Firebase в main.dart
   - Структура коллекций/документов: основная коллекция notes. Структура документа: {
     "title": "string",
     "content": "string",
     "createdAt": "timestamp",
     "updatedAt": "timestamp"
     }
   - Установленные правила безопасности:
     rules_version = '2';
       service cloud.firestore {
         match /databases/{database}/documents {
           match /{document=**} {
             allow read, write: if true;
           }
         }
     }
      Почему правила безопасности недостаточны для продакшена: разрешают доступ всем пользователям, включая неаутентифицированных; любой пользователь может читать и изменять все документы в базе; нет привязки к конкретным пользователям.


Контрольные точки:
1. 