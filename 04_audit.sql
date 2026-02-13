-- ============================================================
-- АУДИТ ДЕЙСТВИЙ ПОЛЬЗОВАТЕЛЕЙ
-- ============================================================

-- Расширение для логирования (опционально, если доступно)
-- CREATE EXTENSION IF NOT EXISTS pgaudit;

-- Функция записи в audit_log (вызывается из приложения или дополнительных триггеров)
CREATE OR REPLACE FUNCTION audit_action(
    p_action VARCHAR(50),
    p_table_name VARCHAR(50) DEFAULT NULL,
    p_record_id INTEGER DEFAULT NULL,
    p_details TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO audit_log (username, action, table_name, record_id, details)
    VALUES (current_user, p_action, p_table_name, p_record_id, p_details);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Триггер аудита на критичные операции (дополнительно к change_log)
CREATE OR REPLACE FUNCTION audit_critical_ops()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM audit_action('DELETE', TG_TABLE_NAME, OLD.id, 
            format('Удалена запись: %s', row_to_json(OLD)::text));
    ELSIF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'readers' THEN
        PERFORM audit_action('NEW_READER', TG_TABLE_NAME, NEW.id, 
            format('Новый читатель: %s', NEW.full_name));
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_audit_authors ON authors
    AFTER DELETE FOR EACH ROW EXECUTE FUNCTION audit_critical_ops();
CREATE TRIGGER tr_audit_books ON books
    AFTER DELETE FOR EACH ROW EXECUTE FUNCTION audit_critical_ops();
CREATE TRIGGER tr_audit_readers_insert ON readers
    AFTER INSERT FOR EACH ROW EXECUTE FUNCTION audit_critical_ops();
CREATE TRIGGER tr_audit_readers_delete ON readers
    AFTER DELETE FOR EACH ROW EXECUTE FUNCTION audit_critical_ops();
