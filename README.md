## Практика 9. Петрова Кристина ЭФБО-06-23

1. База данных Supabase:
![img.png](img.png)
2. Созданные политики базы данных:
![img_1.png](img_1.png)
3. Хранилище Supabase для картинок: 
![img_2.png](img_2.png)
4. Политики для хранилища:
![img_3.png](img_3.png)
5. Регистрация/вход пользователя:
![img_4.png](img_4.png)
6. Экран заметок:
![img_5.png](img_5.png)
7. Создание заметки:
![img_6.png](img_6.png)
![img_8.png](img_8.png)
8. Редактирование заметки:
![img_9.png](img_9.png)
![img_10.png](img_10.png)
9. Удаление заметки c Undo:
![img_11.png](img_11.png)

Шаги подключения Supabase:
1. Переход на официальный сайт Supabase и последующая регистрация с созданием проекта.
2. Создание таблицы notes с полями: id, user_id, title, content, created_at, updated_at, image_url.
3. Подключение RLS и настройка политик.
4. Получение ключей в API-keys и URL в настройках проекта.
5. Все зависимости были подключены в pubspec.yaml:
![img_12.png](img_12.png)
6. Инициализация в main.dart: await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
7. Создание индексов в Supabase:
![img_13.png](img_13.png)
![img_14.png](img_14.png)
![img_15.png](img_15.png)

Таблица notes:
- id uuid PRIMARY KEY - уникальный идентификатор
- user_id uuid NOT NULL - связь с пользователем
- title text - заголовок заметки
- content text - текст заметки
- image_url text - ссылка на изображение
- created_at/updated_at timestamptz - метки времени

RLS-политики:
- Включен Row Level Security для всей таблицы
- Политики для SELECT, INSERT, UPDATE, DELETE с проверкой user_id = auth.uid()
- Каждый пользователь имеет доступ только к своим заметкам

Безопасность в продакшене
- Оставить только аутентифицированных пользователей (authenticated)
- Сохранить политики на основе auth.uid() для изоляции данных
- Добавить валидацию входных данных на стороне клиента и сервера
- Реализовать ограничения на размер загружаемых файлов