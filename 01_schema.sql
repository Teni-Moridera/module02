-- ============================================================
-- СХЕМА БАЗЫ ДАННЫХ "БИБЛИОТЕКА"
-- Тематика: учёт книг, авторов, читателей и выдачи
-- ============================================================

-- Сброс при пересоздании
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS change_log CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS readers CASCADE;

-- 1. Авторы
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    birth_year INTEGER,
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Книги
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    author_id INTEGER NOT NULL REFERENCES authors(id) ON DELETE RESTRICT,
    isbn VARCHAR(20) UNIQUE,
    year_published INTEGER,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Читатели
CREATE TABLE readers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    passport VARCHAR(20) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    registration_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Выдачи книг
CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    reader_id INTEGER NOT NULL REFERENCES readers(id) ON DELETE RESTRICT,
    loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
    return_date DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'returned', 'overdue')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Журнал изменений (для триггеров)
CREATE TABLE change_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

-- 6. Аудит действий пользователей
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50),
    record_id INTEGER,
    details TEXT,
    ip_address INET,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для производительности
CREATE INDEX idx_books_author ON books(author_id);
CREATE INDEX idx_loans_book ON loans(book_id);
CREATE INDEX idx_loans_reader ON loans(reader_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_change_log_table ON change_log(table_name);
CREATE INDEX idx_change_log_time ON change_log(changed_at);
CREATE INDEX idx_audit_log_user ON audit_log(username);
CREATE INDEX idx_audit_log_time ON audit_log(executed_at);

-- Ограничения целостности
ALTER TABLE loans ADD CONSTRAINT chk_loan_dates CHECK (return_date IS NULL OR return_date >= loan_date);
