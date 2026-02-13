# База данных «Библиотека» — защита и целостность

Практическая работа по обеспечению безопасности БД (PostgreSQL).

## Структура

| Файл | Описание |
|------|----------|
| `01_schema.sql` | Схема БД (authors, books, readers, loans, change_log, audit_log) |
| `02_users_roles.sql` | Пользователи, роли, разграничение доступа |
| `03_triggers.sql` | Триггеры журнала изменений и контроля |
| `04_audit.sql` | Аудит критичных операций |
| `05_backup.bat` / `05_backup.sh` | Резервное копирование |
| `06_integrity.sql` | Проверки целостности |
| `07_demo_data.sql` | Демо-данные |
| `SECURITY_POLICY.md` | Политика безопасности |

## Установка

```powershell
.\run_setup.ps1
```

Или вручную: `CREATE DATABASE practice6;` затем выполнить скрипты 01–04 и 07.

## Публикация на GitHub

1. Создай репозиторий на [github.com/new](https://github.com/new) (название, например, `practice6`).
2. Выполни в папке проекта:

```powershell
git remote add origin https://github.com/ТВОЙ_ЛОГИН/practice6.git
git branch -M main
git push -u origin main
```

Если репозиторий уже создан и remote добавлен:

```powershell
git push -u origin main
```
