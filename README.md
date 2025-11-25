# Практическая работа 11

## Выполнила Петрова Кристина ЭФБО-06-23.

Ход работы:
1. Настройка проекта и зависимостей
![img.png](img.png)
2. Создание модели данных (/lib/models/note.dart)
![img_1.png](img_1.png)
3. Реализация API-клиента с ретраями (lib/data/api_client.dart)
![img_20.png](img_20.png)
![img_3.png](img_3.png)
4. Создание репозитория с методами CRUD (lib/data/notes_repository.dart)
![img_2.png](img_2.png)
![img_4.png](img_4.png)
5. Реализация основного экрана с пагинацией и поиском (lib/pages/notes_page.dart)
![img_7.png](img_7.png)
![img_6.png](img_6.png)
6. Создание экрана с деталью заметки
![img_8.png](img_8.png)

Скриншоты:
- Экран списка:
![img_9.png](img_9.png)
- Экран деталей:
![img_10.png](img_10.png)
- Диалог создания и результат:
![img_11.png](img_11.png)
![img_13.png](img_13.png)
- Удаление заметки:
![img_14.png](img_14.png)

Дополнительно:
- Поиск:
![img_12.png](img_12.png)
- ретраи c экспоненциальной паузой:
![img_18.png](img_18.png)
- Undo на удаление:
![img_16.png](img_16.png)
- Pull-to-refresh (notes_page.dart):
![img_17.png](img_17.png)
- .env
![img_19.png](img_19.png)


Крактий отчет:
- Вариант A - JSONPlaceholder API
- Базовый URL: https://jsonplaceholder.typicode.com
  - GET /posts - получение списка заметок
  GET /posts/{id} - получение конкретной заметки
  POST /posts - создание заметки
  PATCH /posts/{id} - обновление заметки
  DELETE /posts/{id} - удаление заметки
- Модель включает конструктор fromJson для преобразования JSON в Dart-объекты.
- Репозиторий инкапсулирует всю логику работы с API, обеспечивая разделение слоёв данных и UI.
- Пагинация: бесконечная прокрутка с подгрузкой по 20 элементов, параметры запроса: _page и _limit, автоматическая подгрузка при достижении конца списка.
- Таймауты: ![img_15.png](img_15.png)
- UX состояния: Loading: индикатор прогресса при первичной загрузке 
                Empty: сообщение при отсутствии данных
                Error: SnackBar с описанием ошибки и возможностью повтора 
                Data: отображение списка с пагинацией


