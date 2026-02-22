# Получение токена Yandex Direct API v5

## Шаг 1: Зарегистрируйте приложение

1. Перейдите на https://oauth.yandex.ru/client/new
2. Укажите название приложения
3. В разделе «Платформы» выберите «Веб-сервисы»
4. В «Права» добавьте: **Яндекс.Директ** → `direct:api`
5. Сохраните `client_id`

## Шаг 2: Получите OAuth токен

Откройте в браузере:

```
https://oauth.yandex.ru/authorize?response_type=token&client_id=ВАШ_CLIENT_ID
```

После авторизации токен будет в URL:
```
https://oauth.yandex.ru/#access_token=ВАШТОКЕН&token_type=bearer&expires_in=31536000
```

## Шаг 3: Настройте токен

```bash
cp config/.env.example config/.env
```

Вставьте токен:
```
YANDEX_DIRECT_TOKEN=ваш_токен_здесь
```

## Проверка

```bash
bash scripts/check_connection.sh
```

## Песочница (Sandbox)

Для тестирования без реальных данных используйте песочницу:
```
YANDEX_DIRECT_SANDBOX=true
```

URL песочницы: `https://api-sandbox.direct.yandex.com/json/v5/`

## Агентские аккаунты

Для работы от имени клиента укажите:
```
YANDEX_DIRECT_CLIENT_LOGIN=логин_клиента
```

## Частые проблемы

### "Unauthorized" (401)
- Токен устарел → получите новый
- Нет прав `direct:api` → пересоздайте приложение

### "Insufficient units" (9000)
- Превышен лимит API-единиц → подождите до полуночи по МСК

## Срок жизни токена

Токен действует **1 год**. После истечения получите новый.

## Документация

- Direct API v5: https://yandex.ru/dev/direct/doc/dg/concepts/about.html
- Песочница: https://yandex.ru/dev/direct/doc/dg/concepts/sandbox.html
- Лимиты: https://yandex.ru/dev/direct/doc/dg/concepts/limits.html
