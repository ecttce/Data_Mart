CREATE TABLE IF NOT EXISTS genres (
    genre_id            SERIAL PRIMARY KEY,
    name                VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS languages (
    language_id         SERIAL PRIMARY KEY,
    name                VARCHAR(100) NOT NULL UNIQUE,
    code                CHAR(2) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS publishers (
    publisher_id        SERIAL PRIMARY KEY,
    name                VARCHAR(200) NOT NULL,
    country             VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS book_conditions (
    condition_id        SERIAL PRIMARY KEY,
    label               VARCHAR(50) NOT NULL,
    description         TEXT
);

-- VERBESSERUNG: Separate authors-Tabelle für bessere 3NF-Normalisierung
CREATE TABLE IF NOT EXISTS authors (
    author_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    birth_year  SMALLINT,
    nationality VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS users ( 
    user_id             SERIAL PRIMARY KEY,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100) NOT NULL,
    email               VARCHAR(200) NOT NULL UNIQUE,
    phone               VARCHAR(30),
    street              VARCHAR(200),
    city                VARCHAR(100),
    postal_code         VARCHAR(20),
    country             VARCHAR(100) DEFAULT 'Germany',
    latitude            DECIMAL(9,6),
    longitude           DECIMAL(9,6), 
    registered_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS books (
    book_id        SERIAL PRIMARY KEY,
    isbn           VARCHAR(20) UNIQUE,
    title          VARCHAR(300) NOT NULL,
    -- author bleibt als Fallback für Legacy-Daten, neu: author_id FK
    author         VARCHAR(200),
    author_id      INT REFERENCES authors(author_id),
    publisher_id   INT REFERENCES publishers(publisher_id),
    genre_id       INT REFERENCES genres(genre_id),
    language_id    INT REFERENCES languages(language_id),
    year_published SMALLINT,
    description    TEXT
);

-- M:N zwischen books und authors (ein Buch kann mehrere Autoren haben)
CREATE TABLE IF NOT EXISTS book_authors (
    book_id   INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES authors(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE IF NOT EXISTS book_copies ( 
    copy_id             SERIAL PRIMARY KEY,
    book_id             INT NOT NULL REFERENCES books(book_id),
    owner_id            INT NOT NULL REFERENCES users(user_id),
    condition_id        INT NOT NULL REFERENCES book_conditions(condition_id),
    max_loan_days       SMALLINT NOT NULL DEFAULT 14,
    allow_post          BOOLEAN NOT NULL DEFAULT FALSE,
    pickup_address      VARCHAR(300),
    pickup_latitude     DECIMAL(9,6),
    pickup_longitude    DECIMAL(9,6),
    is_available        BOOLEAN NOT NULL DEFAULT TRUE,
    added_at            TIMESTAMP NOT NULL DEFAULT NOW() 
);

CREATE TABLE IF NOT EXISTS time_slots ( 
    slot_id             SERIAL PRIMARY KEY,
    copy_id             INT NOT NULL REFERENCES book_copies(copy_id),
    day_of_week         SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time          TIME NOT NULL,
    end_time            TIME NOT NULL,
    CONSTRAINT chk_slot_times CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS loans ( 
    loan_id             SERIAL PRIMARY KEY,
    copy_id             INT NOT NULL REFERENCES book_copies(copy_id),
    borrower_id         INT NOT NULL REFERENCES users(user_id),
    slot_id             INT REFERENCES time_slots(slot_id),
    loaned_at           DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date            DATE NOT NULL,
    returned_at         DATE,
    is_via_post         BOOLEAN NOT NULL DEFAULT FALSE,
    status              VARCHAR(20) NOT NULL DEFAULT 'active' 
                        CHECK (status IN ('active','returned','overdue','cancelled'))
);

CREATE TABLE IF NOT EXISTS ratings ( 
    rating_id           SERIAL PRIMARY KEY,
    loan_id             INT NOT NULL UNIQUE REFERENCES loans(loan_id),
    reviewer_id         INT NOT NULL REFERENCES users(user_id),
    book_id             INT NOT NULL REFERENCES books(book_id),
    score               SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    comment             TEXT,
    rated_at            TIMESTAMP NOT NULL DEFAULT NOW() 
);

CREATE TABLE IF NOT EXISTS messages ( 
    message_id          SERIAL PRIMARY KEY,
    sender_id           INT NOT NULL REFERENCES users(user_id),
    receiver_id         INT NOT NULL REFERENCES users(user_id),
    copy_id             INT REFERENCES book_copies(copy_id),
    subject             VARCHAR(200),
    body                TEXT NOT NULL,
    sent_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    is_read             BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_different_users CHECK (sender_id <> receiver_id)
);

CREATE TABLE IF NOT EXISTS wishlist (
    wishlist_id         SERIAL PRIMARY KEY,
    user_id             INT NOT NULL REFERENCES users(user_id),
    book_id             INT NOT NULL REFERENCES books(book_id),
    added_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, book_id)
);

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_book_copies_owner    ON book_copies(owner_id);
CREATE INDEX IF NOT EXISTS idx_book_copies_book     ON book_copies(book_id);
CREATE INDEX IF NOT EXISTS idx_loans_borrower       ON loans(borrower_id);
CREATE INDEX IF NOT EXISTS idx_loans_copy           ON loans(copy_id);
CREATE INDEX IF NOT EXISTS idx_loans_status         ON loans(status);
CREATE INDEX IF NOT EXISTS idx_ratings_book         ON ratings(book_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver    ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender      ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_user        ON wishlist(user_id);
CREATE INDEX IF NOT EXISTS idx_time_slots_copy      ON time_slots(copy_id);
CREATE INDEX IF NOT EXISTS idx_book_authors_book    ON book_authors(book_id);
CREATE INDEX IF NOT EXISTS idx_book_authors_author  ON book_authors(author_id);

-- ============================================================
-- Trigger für automatische Statusänderungen
-- (VERBESSERUNG: Geschäftslogik über Trigger)
-- ============================================================

-- Funktion: Setzt überfällige Ausleihen automatisch auf 'overdue'
CREATE OR REPLACE FUNCTION fn_update_overdue_loans()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE loans
    SET status = 'overdue'
    WHERE status = 'active'
      AND due_date < CURRENT_DATE
      AND returned_at IS NULL;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Wird täglich bei jedem INSERT auf loans ausgeführt
CREATE OR REPLACE TRIGGER trg_check_overdue
    AFTER INSERT ON loans
    FOR EACH STATEMENT
    EXECUTE FUNCTION fn_update_overdue_loans();

-- Funktion: Setzt is_available = FALSE wenn Ausleihe aktiv wird
CREATE OR REPLACE FUNCTION fn_set_copy_unavailable()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'active' THEN
        UPDATE book_copies SET is_available = FALSE WHERE copy_id = NEW.copy_id;
    ELSIF NEW.status IN ('returned', 'cancelled') THEN
        UPDATE book_copies SET is_available = TRUE WHERE copy_id = NEW.copy_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_loan_availability
    AFTER INSERT OR UPDATE OF status ON loans
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_copy_unavailable();