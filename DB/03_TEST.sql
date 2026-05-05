-- ============================================================
-- TESTFÄLLE: Buchtausch-App Datenbank
-- Zweck:  Validierung des ER-Modells durch gezielte SQL-Tests
-- DBMS:   PostgreSQL
-- ============================================================
-- Voraussetzung: CREATE_TABLES.sql und CREATE_DUMMY_DATA.sql wurden bereits ausgeführt
-- ============================================================


-- ============================================================
-- TESTBLOCK 1: KARDINALITÄTEN (1:N Beziehungen)
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 1: Kardinalitäten (1:N)'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 1.1: users -> book_copies (1:N)
-- Ein Nutzer kann mehrere Exemplare besitzen.
-- Erwartung: mindestens ein Nutzer mit mehr als 1 Exemplar.
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 1.1: users -> book_copies (1:N) ---'; END $$;

SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name  AS user,
    COUNT(bc.copy_id)                   AS number_of_copies
FROM users u
JOIN book_copies bc ON bc.owner_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY number_of_copies DESC
LIMIT 5;

DO $$
DECLARE
    v_multiple INT;
    v_result   INT;
BEGIN
    SELECT COUNT(*) INTO v_multiple
    FROM (
        SELECT u.user_id, COUNT(bc.copy_id) AS number_of_copies
        FROM users u
        JOIN book_copies bc ON bc.owner_id = u.user_id
        GROUP BY u.user_id
        HAVING COUNT(bc.copy_id) > 1
    ) sub;

    SELECT COUNT(DISTINCT owner_id) INTO v_result FROM book_copies;

    RAISE NOTICE 'Testfall 1.1: Nutzer mit Exemplaren: %, davon mit >1 Exemplar: %', v_result, v_multiple;

    IF v_multiple > 0 THEN
        RAISE NOTICE 'Testfall 1.1: PASS -- % Nutzer besitzen mehr als 1 Exemplar (1:N bestätigt)', v_multiple;
    ELSE
        RAISE NOTICE 'Testfall 1.1: HINWEIS -- Jeder Nutzer hat genau 1 Exemplar in Testdaten (1:N möglich, aber nicht belegt)';
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 1.2: books -> book_copies (1:N)
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 1.2: books -> book_copies (1:N) ---'; END $$;

SELECT
    b.book_id,
    b.title,
    COUNT(bc.copy_id) AS number_of_copies
FROM books b
JOIN book_copies bc ON bc.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY number_of_copies DESC
LIMIT 5;

DO $$
DECLARE
    v_multiple INT;
    v_result   INT;
BEGIN
    SELECT COUNT(*) INTO v_multiple
    FROM (
        SELECT b.book_id, COUNT(bc.copy_id) AS number_of_copies
        FROM books b
        JOIN book_copies bc ON bc.book_id = b.book_id
        GROUP BY b.book_id
        HAVING COUNT(bc.copy_id) > 1
    ) sub;

    -- Gesamtanzahl Titel mit mind. 1 Exemplar
    SELECT COUNT(DISTINCT book_id) INTO v_result FROM book_copies;

    RAISE NOTICE 'Testfall 1.2: Gesamt Titel mit Exemplaren: %, davon mit >1 Exemplar: %', v_result, v_multiple;

    IF v_multiple > 0 THEN
        RAISE NOTICE 'Testfall 1.2: PASS -- % Titel haben number_of_copies > 1 (1:N bestätigt)', v_multiple;
    ELSE
        RAISE NOTICE 'Testfall 1.2: HINWEIS -- Jeder Titel hat genau 1 Exemplar in Testdaten (1:N möglich, aber nicht belegt)';
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 1.3: book_copies -> time_slots (1:N)
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 1.3: book_copies -> time_slots (1:N) ---'; END $$;

SELECT
    bc.copy_id,
    b.title,
    COUNT(ts.slot_id) AS number_of_slots
FROM book_copies bc
JOIN books      b  ON b.book_id  = bc.book_id
JOIN time_slots ts ON ts.copy_id = bc.copy_id
GROUP BY bc.copy_id, b.title
ORDER BY number_of_slots DESC
LIMIT 5;

DO $$
DECLARE
    v_multiple INT;
    v_result   INT;
BEGIN
    SELECT COUNT(*) INTO v_multiple
    FROM (
        SELECT bc.copy_id, COUNT(ts.slot_id) AS number_of_slots
        FROM book_copies bc
        JOIN time_slots ts ON ts.copy_id = bc.copy_id
        GROUP BY bc.copy_id
        HAVING COUNT(ts.slot_id) > 1
    ) sub;

    SELECT COUNT(DISTINCT copy_id) INTO v_result FROM time_slots;

    RAISE NOTICE 'Testfall 1.3: Exemplare mit Zeitslots: %, davon mit >1 Slot: %', v_result, v_multiple;

    IF v_multiple > 0 THEN
        RAISE NOTICE 'Testfall 1.3: PASS -- % Exemplare haben mehrere Zeitslots (1:N bestätigt)', v_multiple;
    ELSE
        RAISE NOTICE 'Testfall 1.3: HINWEIS -- Jedes Exemplar hat genau 1 Zeitslot in Testdaten (1:N möglich, aber nicht belegt)';
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 1.4: loans -> ratings (1:1, UNIQUE)
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 1.4: loans -> ratings (1:1, UNIQUE) ---'; END $$;

SELECT
    l.loan_id,
    COUNT(r.rating_id) AS number_of_ratings
FROM loans l
LEFT JOIN ratings r ON r.loan_id = l.loan_id
GROUP BY l.loan_id
ORDER BY number_of_ratings DESC
LIMIT 5;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM (
        SELECT loan_id FROM ratings GROUP BY loan_id HAVING COUNT(*) > 1
    ) sub;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 1.4: PASS -- Keine loan_id hat mehr als 1 Bewertung (1:1 bestätigt)';
    ELSE
        RAISE NOTICE 'Testfall 1.4: FAIL -- % loan_ids haben mehr als 1 Bewertung!', v;
    END IF;
END $$;


-- ============================================================
-- TESTBLOCK 2: M:N BEZIEHUNG (wishlist)
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 2: M:N Beziehung (wishlist)'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 2.1: Wunschliste -- jede Kombination nur einmal
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 2.1: wishlist UNIQUE(user_id, book_id) ---'; END $$;

SELECT
    u.first_name || ' ' || u.last_name AS user,
    COUNT(w.book_id)                   AS wishlist_entry
FROM users u
JOIN wishlist w ON w.user_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY wishlist_entry DESC;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM (
        SELECT user_id, book_id FROM wishlist
        GROUP BY user_id, book_id HAVING COUNT(*) > 1
    ) sub;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 2.1: PASS -- Keine doppelten (user_id, book_id) in wishlist';
    ELSE
        RAISE NOTICE 'Testfall 2.1: FAIL -- % doppelte Kombinationen!', v;
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 2.2: UNIQUE-Constraint -- Duplikat-Insert (Negativtest)
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 2.2: wishlist Duplikat-Insert (Negativtest) ---'; END $$;

DO $$
DECLARE v_uid INT; v_bid INT;
BEGIN
    SELECT user_id, book_id INTO v_uid, v_bid FROM wishlist LIMIT 1;
    IF v_uid IS NULL THEN
        RAISE NOTICE 'Testfall 2.2: ÜBERSPRUNGEN -- keine Daten in wishlist';
        RETURN;
    END IF;
    BEGIN
        INSERT INTO wishlist (user_id, book_id) VALUES (v_uid, v_bid);
        RAISE NOTICE 'Testfall 2.2: FAIL -- Duplikat wurde akzeptiert!';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Testfall 2.2: PASS -- Duplikat korrekt abgelehnt (unique_violation)';
    END;
END $$;


-- ============================================================
-- TESTBLOCK 3: TERNÄRE BEZIEHUNGEN
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 3: Ternäre Beziehungen'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 3.1: TERNÄR loans
-- users (borrower) x book_copies x time_slots
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 3.1: Ternäre Beziehung LOANS ---'; END $$;

SELECT
    l.loan_id,
    u.first_name || ' ' || u.last_name    AS loaner,
    b.title                               AS book,
    CASE ts.day_of_week
        WHEN 0 THEN 'Mo' WHEN 1 THEN 'Di' WHEN 2 THEN 'Mi'
        WHEN 3 THEN 'Do' WHEN 4 THEN 'Fr' WHEN 5 THEN 'Sa'
        ELSE 'So'
    END                                   AS weekday,
    ts.start_time::TEXT || ' - ' || ts.end_time::TEXT AS timeframe,
    l.status
FROM loans       l
JOIN users       u  ON u.user_id   = l.borrower_id
JOIN book_copies bc ON bc.copy_id  = l.copy_id
JOIN books       b  ON b.book_id   = bc.book_id
JOIN time_slots  ts ON ts.slot_id  = l.slot_id
ORDER BY l.loan_id;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM loans l
    JOIN users       u  ON u.user_id  = l.borrower_id
    JOIN book_copies bc ON bc.copy_id = l.copy_id
    JOIN books       b  ON b.book_id  = bc.book_id
    JOIN time_slots  ts ON ts.slot_id = l.slot_id;
    IF v > 0 THEN
        RAISE NOTICE 'Testfall 3.1: PASS -- % Ausleihen vollständig über 4 Tabellen verknüpft', v;
    ELSE
        RAISE NOTICE 'Testfall 3.1: HINWEIS -- Keine Ausleihen in Testdaten';
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 3.2: TERNÄR ratings
-- users (reviewer) x books x loans
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 3.2: Ternäre Beziehung RATINGS ---'; END $$;

SELECT
    r.rating_id,
    u.first_name || ' ' || u.last_name  AS reviewer,
    b.title                             AS book,
    r.score                             AS rating,
    l.loan_id                           AS loan_id,
    r.rated_at::DATE                    AS date
FROM ratings r
JOIN users u ON u.user_id = r.reviewer_id
JOIN books b ON b.book_id = r.book_id
JOIN loans l ON l.loan_id = r.loan_id
ORDER BY r.rating_id;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM ratings r
    JOIN users u ON u.user_id = r.reviewer_id
    JOIN books b ON b.book_id = r.book_id
    JOIN loans l ON l.loan_id = r.loan_id;
    IF v > 0 THEN
        RAISE NOTICE 'Testfall 3.2: PASS -- % Bewertungen vollständig über 4 Tabellen verknüpft', v;
    ELSE
        RAISE NOTICE 'Testfall 3.2: HINWEIS -- Keine Bewertungen in Testdaten';
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 3.3: TERNÄR messages -- Self-Join auf users
-- users (sender) x users (receiver) x book_copies
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 3.3: Ternäre Beziehung MESSAGES (Self-Join) ---'; END $$;

SELECT
    m.message_id,
    s.first_name || ' ' || s.last_name   AS sender,
    e.first_name || ' ' || e.last_name   AS receiver,
    b.title                              AS book,
    m.subject,
    m.is_read
FROM messages    m
JOIN users       s  ON s.user_id  = m.sender_id
JOIN users       e  ON e.user_id  = m.receiver_id
JOIN book_copies bc ON bc.copy_id = m.copy_id
JOIN books       b  ON b.book_id  = bc.book_id
ORDER BY m.sent_at DESC;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM messages m
    JOIN users       s  ON s.user_id  = m.sender_id
    JOIN users       e  ON e.user_id  = m.receiver_id
    JOIN book_copies bc ON bc.copy_id = m.copy_id;
    IF v > 0 THEN
        RAISE NOTICE 'Testfall 3.3: PASS -- % Nachrichten vollständig verknüpft (Self-Join bestätigt)', v;
    ELSE
        RAISE NOTICE 'Testfall 3.3: HINWEIS -- Keine Nachrichten in Testdaten';
    END IF;
END $$;


-- ============================================================
-- TESTBLOCK 4: FREMDSCHLÜSSEL-INTEGRITÄT (Negativtests)
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 4: Fremdschlüssel-Integrität'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 4.1: book_copies mit ungültigem owner_id
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 4.1: FK book_copies.owner_id (Negativtest) ---'; END $$;

DO $$
BEGIN
    INSERT INTO book_copies (book_id, owner_id, condition_id)
    VALUES (1, 99999, 1);
    RAISE NOTICE 'Testfall 4.1: FAIL -- Ungültige owner_id wurde akzeptiert!';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Testfall 4.1: PASS -- FK-Verletzung korrekt abgelehnt (owner_id 99999 existiert nicht)';
END $$;


-- ----------------------------------------------------------
-- Testfall 4.2: loans mit ungültigem borrower_id
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 4.2: FK loans.borrower_id (Negativtest) ---'; END $$;

DO $$
BEGIN
    INSERT INTO loans (copy_id, borrower_id, slot_id, due_date)
    VALUES (1, 88888, 1, CURRENT_DATE + 14);
    RAISE NOTICE 'Testfall 4.2: FAIL -- Ungültige borrower_id wurde akzeptiert!';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Testfall 4.2: PASS -- FK-Verletzung korrekt abgelehnt (borrower_id 88888 existiert nicht)';
END $$;


-- ----------------------------------------------------------
-- Testfall 4.3: ratings mit ungültigem loan_id
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 4.3: FK ratings.loan_id (Negativtest) ---'; END $$;

DO $$
BEGIN
    INSERT INTO ratings (loan_id, reviewer_id, book_id, score)
    VALUES (77777, 1, 1, 4);
    RAISE NOTICE 'Testfall 4.3: FAIL -- Ungültige loan_id wurde akzeptiert!';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Testfall 4.3: PASS -- FK-Verletzung korrekt abgelehnt (loan_id 77777 existiert nicht)';
END $$;


-- ============================================================
-- TESTBLOCK 5: CHECK-CONSTRAINTS
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 5: CHECK-Constraints'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 5.1: score außerhalb 1-5 in ratings
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 5.1: CHECK score BETWEEN 1 AND 5 ---'; END $$;

DO $$
DECLARE v_loan_id INT; v_uid INT; v_bid INT;
BEGIN
    SELECT l.loan_id, l.borrower_id, bc.book_id
    INTO v_loan_id, v_uid, v_bid
    FROM loans l
    JOIN book_copies bc ON bc.copy_id = l.copy_id
    WHERE l.loan_id NOT IN (SELECT loan_id FROM ratings)
    LIMIT 1;

    IF v_loan_id IS NULL THEN
        RAISE NOTICE 'Testfall 5.1: ÜBERSPRUNGEN -- keine unbewertete Ausleihe verfügbar';
        RETURN;
    END IF;

    BEGIN
        INSERT INTO ratings (loan_id, reviewer_id, book_id, score)
        VALUES (v_loan_id, v_uid, v_bid, 6);
        RAISE NOTICE 'Testfall 5.1: FAIL -- score=6 wurde akzeptiert!';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Testfall 5.1: PASS -- CHECK-Constraint korrekt ausgelöst (score=6 abgelehnt)';
    END;
END $$;


-- ----------------------------------------------------------
-- Testfall 5.2: day_of_week ausserhalb 0-6
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 5.2: CHECK day_of_week BETWEEN 0 AND 6 ---'; END $$;

DO $$
BEGIN
    INSERT INTO time_slots (copy_id, day_of_week, start_time, end_time)
    VALUES (1, 8, '10:00', '12:00');
    RAISE NOTICE 'Testfall 5.2: FAIL -- day_of_week=8 wurde akzeptiert!';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Testfall 5.2: PASS -- CHECK-Constraint korrekt ausgelöst (day_of_week=8 abgelehnt)';
END $$;


-- ----------------------------------------------------------
-- Testfall 5.3: end_time <= start_time
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 5.3: CHECK end_time > start_time ---'; END $$;

DO $$
BEGIN
    INSERT INTO time_slots (copy_id, day_of_week, start_time, end_time)
    VALUES (1, 1, '14:00', '10:00');
    RAISE NOTICE 'Testfall 5.3: FAIL -- end_time < start_time wurde akzeptiert!';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Testfall 5.3: PASS -- CHECK-Constraint korrekt ausgelöst (end <= start abgelehnt)';
END $$;


-- ----------------------------------------------------------
-- Testfall 5.4: ungültigem status in loans
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 5.4: CHECK status IN (...) ---'; END $$;

DO $$
BEGIN
    UPDATE loans SET status = 'ungültig' WHERE loan_id = 1;
    RAISE NOTICE 'Testfall 5.4: FAIL -- status=ungültig wurde akzeptiert!';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Testfall 5.4: PASS -- CHECK-Constraint korrekt ausgelöst (status=ungültig abgelehnt)';
END $$;


-- ============================================================
-- TESTBLOCK 6: DATENKONSISTENZ
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 6: Datenkonsistenz'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 6.1: Jedes Exemplar hat gültigen Besitzer
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 6.1: Jedes book_copy hat gültigen owner ---'; END $$;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM book_copies bc
    LEFT JOIN users u ON u.user_id = bc.owner_id
    WHERE u.user_id IS NULL;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 6.1: PASS -- Alle Exemplare haben einen gültigen Besitzer';
    ELSE
        RAISE NOTICE 'Testfall 6.1: FAIL -- % verwaiste Exemplare!', v;
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 6.2: sender_id != receiver_id in messages
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 6.2: sender != receiver in messages ---'; END $$;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM messages WHERE sender_id = receiver_id;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 6.2: PASS -- Kein Nutzer hat sich selbst eine Nachricht gesendet';
    ELSE
        RAISE NOTICE 'Testfall 6.2: FAIL -- % Nachrichten mit sender = receiver!', v;
    END IF;
END $$;

DO $$ BEGIN RAISE NOTICE '--- Testfall 6.2b: Selbst-Nachricht einfügen (Negativtest) ---'; END $$;

DO $$
DECLARE v_uid INT; v_cid INT;
BEGIN
    SELECT sender_id, copy_id INTO v_uid, v_cid FROM messages LIMIT 1;
    IF v_uid IS NULL THEN
        RAISE NOTICE 'Testfall 6.2b: ÜBERSPRUNGEN -- keine messages vorhanden';
        RETURN;
    END IF;
    BEGIN
        INSERT INTO messages (sender_id, receiver_id, copy_id, subject, body)
        VALUES (v_uid, v_uid, v_cid, 'Test', 'Selbst-Nachricht');
        RAISE NOTICE 'Testfall 6.2b: FAIL -- Selbst-Nachricht wurde akzeptiert!';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Testfall 6.2b: PASS -- CHECK-Constraint korrekt ausgelöst (sender=receiver abgelehnt)';
    END;
END $$;


-- ----------------------------------------------------------
-- Testfall 6.3: due_date liegt nach loaned_at
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 6.3: due_date > loaned_at ---'; END $$;

SELECT loan_id, loaned_at, due_date,
       (due_date - loaned_at) AS loan_period
FROM loans
ORDER BY loan_id;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v FROM loans WHERE due_date <= loaned_at;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 6.3: PASS -- Alle Ausleihen haben due_date nach loaned_at';
    ELSE
        RAISE NOTICE 'Testfall 6.3: FAIL -- % Ausleihen mit ungültigem Datum!', v;
    END IF;
END $$;


-- ============================================================
-- TESTBLOCK 7: NORMALISIERUNG 3NF (Lookup-Tabellen)
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTBLOCK 7: Normalisierung 3NF'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;


-- ----------------------------------------------------------
-- Testfall 7.1: books.genre_id -> genres
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 7.1: books.genre_id -> genres ---'; END $$;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM books b
    LEFT JOIN genres g ON g.genre_id = b.genre_id
    WHERE b.genre_id IS NOT NULL AND g.genre_id IS NULL;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 7.1: PASS -- Alle Bücher haben gültiges Genre';
    ELSE
        RAISE NOTICE 'Testfall 7.1: FAIL -- % Bücher mit ungültigem genre_id!', v;
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 7.2: books.language_id -> languages
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 7.2: books.language_id -> languages ---'; END $$;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM books b
    LEFT JOIN languages l ON l.language_id = b.language_id
    WHERE b.language_id IS NOT NULL AND l.language_id IS NULL;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 7.2: PASS -- Alle Bücher haben gültige Sprache';
    ELSE
        RAISE NOTICE 'Testfall 7.2: FAIL -- % Bücher mit ungültiger language_id!', v;
    END IF;
END $$;


-- ----------------------------------------------------------
-- Testfall 7.3: book_copies.condition_id -> book_conditions
-- ----------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testfall 7.3: book_copies.condition_id -> book_conditions ---'; END $$;

DO $$
DECLARE v INT;
BEGIN
    SELECT COUNT(*) INTO v
    FROM book_copies bc
    LEFT JOIN book_conditions c ON c.condition_id = bc.condition_id
    WHERE c.condition_id IS NULL;
    IF v = 0 THEN
        RAISE NOTICE 'Testfall 7.3: PASS -- Alle Exemplare haben gültigen Zustand';
    ELSE
        RAISE NOTICE 'Testfall 7.3: FAIL -- % Exemplare ohne gültigen Zustand!', v;
    END IF;
END $$;


-- ============================================================
-- ABSCHLUSSZUSAMMENFASSUNG
-- ============================================================

DO $$ BEGIN RAISE NOTICE '========================================'; END $$;
DO $$ BEGIN RAISE NOTICE 'TESTLAUF ABGESCHLOSSEN'; END $$;
DO $$ BEGIN RAISE NOTICE 'Ergebnisse s. PASS / FAIL / HINWEIS oben'; END $$;
DO $$ BEGIN RAISE NOTICE ''; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 1 -- Kardinalitäten 1:N  (4 Tests)'; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 2 -- M:N Beziehung        (2 Tests)'; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 3 -- Ternäre Beziehungen  (3 Tests)'; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 4 -- FK-Integrität       (3 Negativtests)'; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 5 -- CHECK-Constraints    (4 Negativtests)'; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 6 -- Datenkonsistenz      (3 Tests)'; END $$;
DO $$ BEGIN RAISE NOTICE 'Block 7 -- Normalisierung 3NF   (3 Tests)'; END $$;
DO $$ BEGIN RAISE NOTICE '------------------------------'; END $$;
DO $$ BEGIN RAISE NOTICE 'Gesamt: 22 Testfälle'; END $$;
DO $$ BEGIN RAISE NOTICE '========================================'; END $$;