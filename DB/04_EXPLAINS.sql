-- ============================================================
-- EXPLAIN-Analysen zur Performance-Dokumentation
-- (VERBESSERUNG: Indexwirkung demonstrieren)
-- ============================================================

-- Explain: Abfrage mit Index auf loans.borrower_id
EXPLAIN (FORMAT TEXT)
SELECT l.loan_id, u.first_name, u.last_name, b.title, l.status
FROM loans l
JOIN users u        ON u.user_id    = l.borrower_id
JOIN book_copies bc ON bc.copy_id   = l.copy_id
JOIN books b        ON b.book_id    = bc.book_id
WHERE l.borrower_id = 2;

-- Explain: Bounding-Box-Näherungssuche (ohne PostGIS)
EXPLAIN (FORMAT TEXT)
SELECT bc.copy_id, b.title, u.first_name,
       bc.pickup_latitude, bc.pickup_longitude
FROM book_copies bc
JOIN books b ON b.book_id   = bc.book_id
JOIN users u ON u.user_id   = bc.owner_id
WHERE bc.is_available = TRUE
  AND bc.pickup_latitude  BETWEEN 51.0 AND 53.0
  AND bc.pickup_longitude BETWEEN  8.0 AND 14.0;