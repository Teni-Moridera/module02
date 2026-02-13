-- ============================================================
-- КОНТРОЛЬ ЦЕЛОСТНОСТИ
-- ============================================================

-- Проверка целостности: нет "висящих" выдач (книга/читатель удалены)
-- Выполнять периодически
SELECT 'Orphan loans (invalid book_id):' AS check_type, COUNT(*) 
FROM loans l LEFT JOIN books b ON l.book_id = b.id WHERE b.id IS NULL
UNION ALL
SELECT 'Orphan loans (invalid reader_id):', COUNT(*) 
FROM loans l LEFT JOIN readers r ON l.reader_id = r.id WHERE r.id IS NULL;

-- Проверка: книги с отрицательным quantity (не должно быть)
SELECT 'Books with negative quantity:' AS check_type, COUNT(*) 
FROM books WHERE quantity < 0;

-- Проверка FK: книги без автора
SELECT 'Books without valid author:' AS check_type, COUNT(*) 
FROM books b LEFT JOIN authors a ON b.author_id = a.id WHERE a.id IS NULL;
