-- ============================================================
-- ТРИГГЕРЫ: КОНТРОЛЬ ИЗМЕНЕНИЙ И ЖУРНАЛ
-- ============================================================

-- Функция для логирования изменений в change_log
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
DECLARE
    old_json JSONB;
    new_json JSONB;
BEGIN
    IF TG_OP = 'DELETE' THEN
        old_json := to_jsonb(OLD);
        new_json := NULL;
        INSERT INTO change_log (table_name, operation, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, 'DELETE', old_json, new_json, current_user);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        old_json := to_jsonb(OLD);
        new_json := to_jsonb(NEW);
        INSERT INTO change_log (table_name, operation, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, 'UPDATE', old_json, new_json, current_user);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        new_json := to_jsonb(NEW);
        INSERT INTO change_log (table_name, operation, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, 'INSERT', NULL, new_json, current_user);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Триггеры на основные таблицы
CREATE TRIGGER tr_authors_changelog
    AFTER INSERT OR UPDATE OR DELETE ON authors
    FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER tr_books_changelog
    AFTER INSERT OR UPDATE OR DELETE ON books
    FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER tr_readers_changelog
    AFTER INSERT OR UPDATE OR DELETE ON readers
    FOR EACH ROW EXECUTE FUNCTION log_changes();

CREATE TRIGGER tr_loans_changelog
    AFTER INSERT OR UPDATE OR DELETE ON loans
    FOR EACH ROW EXECUTE FUNCTION log_changes();

-- Триггер контроля: нельзя выдать книгу, если quantity = 0
CREATE OR REPLACE FUNCTION check_book_availability()
RETURNS TRIGGER AS $$
DECLARE
    available INTEGER;
    active_loans INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT quantity INTO available FROM books WHERE id = NEW.book_id;
        SELECT COUNT(*) INTO active_loans FROM loans 
            WHERE book_id = NEW.book_id AND status = 'active';
        IF active_loans >= available THEN
            RAISE EXCEPTION 'Книга с id % недоступна для выдачи (все экземпляры выданы)', NEW.book_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_loans_availability
    BEFORE INSERT ON loans
    FOR EACH ROW EXECUTE FUNCTION check_book_availability();

-- Триггер: автоматическая установка status='returned' при указании return_date
CREATE OR REPLACE FUNCTION set_loan_returned()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        NEW.status := 'returned';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_loans_return
    BEFORE UPDATE ON loans
    FOR EACH ROW EXECUTE FUNCTION set_loan_returned();
