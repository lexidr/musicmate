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
