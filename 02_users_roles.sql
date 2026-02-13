-- ============================================================
-- ПОЛЬЗОВАТЕЛИ, РОЛИ И РАЗГРАНИЧЕНИЕ ДОСТУПА
-- ============================================================

-- Создание ролей
CREATE ROLE admin_role;      -- Полный доступ
CREATE ROLE librarian_role;  -- Работа с книгами и выдачами
CREATE ROLE reader_role;     -- Только чтение
CREATE ROLE auditor_role;    -- Только просмотр журналов аудита

-- Назначение прав admin_role (полный доступ)
GRANT ALL PRIVILEGES ON SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin_role;

-- Назначение прав librarian_role (SELECT, INSERT, UPDATE на основные таблицы)
GRANT USAGE ON SCHEMA public TO librarian_role;
GRANT SELECT, INSERT, UPDATE ON authors, books, readers, loans TO librarian_role;
GRANT SELECT ON change_log, audit_log TO librarian_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO librarian_role;
-- DELETE только для loans (возврат/отмена выдачи)
GRANT DELETE ON loans TO librarian_role;

-- Назначение прав reader_role (только чтение)
GRANT USAGE ON SCHEMA public TO reader_role;
GRANT SELECT ON authors, books, readers TO reader_role;
-- readers видит только свои данные через RLS или представление (упрощённо — SELECT на readers)

-- Назначение прав auditor_role (только журналы)
GRANT USAGE ON SCHEMA public TO auditor_role;
GRANT SELECT ON change_log, audit_log TO auditor_role;

-- Создание пользователей
CREATE USER db_admin WITH PASSWORD 'AdminSecure123!' IN ROLE admin_role;
CREATE USER librarian WITH PASSWORD 'LibSecure456!' IN ROLE librarian_role;
CREATE USER reader_user WITH PASSWORD 'ReadSecure789!' IN ROLE reader_role;
CREATE USER auditor WITH PASSWORD 'AuditSecure000!' IN ROLE auditor_role;

-- Примечание: для применения нужно выполнить на БД practice6.
-- Создание БД: CREATE DATABASE practice6;
