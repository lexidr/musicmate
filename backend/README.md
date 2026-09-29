# musicmate backend

Простой Rails API для musicmate.

## Запуск

Нужны Ruby 4.0 и PostgreSQL.

```bash
bundle install
cp .env.example .env
bundle exec rails db:create db:migrate
bundle exec rails server
```

API будет доступен по адресу `http://localhost:3000`.

Если у PostgreSQL есть имя пользователя и пароль, укажите их в `DATABASE_URL`
в файле `.env`.

## Spotify

Создайте приложение в Spotify Developer Dashboard и добавьте redirect URI:

```text
http://127.0.0.1:3000/api/v1/auth/spotify/callback
```

Затем заполните Spotify-переменные и `JWT_SECRET` в `.env`.

Начать вход можно по адресу:

```text
http://127.0.0.1:3000/api/v1/auth/spotify
```
