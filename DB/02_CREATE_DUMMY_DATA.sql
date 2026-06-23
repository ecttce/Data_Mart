-- genres
INSERT INTO genres
(
    name
)
VALUES ('Novel'),
('Science Fiction'),
('Crime'),
('Fantasy'),
('Non-Fiction'),
('Biography'),
('Thriller'),
('Historical Fiction'),
('Children''s Book'),
('Poetry'),
('Humor'),
('Travel Guide');


-- languages
INSERT INTO languages
(
    name,
    code
)
VALUES
('German', 'de'),
('English', 'en'),
('French', 'fr'),
('Spanish', 'es'),
('Italian', 'it'),
('Dutch', 'nl'),
('Polish', 'pl'),
('Russian', 'ru'),
('Turkish', 'tr'),
('Portuguese', 'pt'),
('Swedish', 'sv'),
('Japanese', 'ja');

-- publishers
INSERT INTO publishers
(
    name,
    country
)
VALUES
('Suhrkamp Verlag', 'Germany'),
('C.H. Beck', 'Germany'),
('Rowohlt Verlag', 'Germany'),
('Penguin Books', 'Great Britain'),
('Random House', 'USA'),
('Hanser Verlag', 'Germany'),
('dtv Verlagsgesellschaft', 'Germany'),
('S. Fischer Verlag', 'Germany'),
('Piper Verlag', 'Germany'),
('Ullstein Buchverlage', 'Germany'),
('Kiepenheuer & Witsch', 'Germany'),
('Bloomsbury Publishing', 'Great Britain');

-- book_conditions
INSERT INTO book_conditions
(
    label,
    description
)
VALUES
('New', 'Unread, perfect condition'),
('Very Good', 'Barely any wear, like new'),
('Good', 'Light signs of use, fully readable'),
('Acceptable', 'Visible signs of use, but complete'),
('Sufficient', 'Heavy signs of use, possible annotations'),
('Poor', 'Significant damage, but readable'),
('Defective', 'Pages missing or severely damaged');

-- VERBESSERUNG: Autoren in eigener Tabelle
INSERT INTO authors 
(
    first_name, 
    last_name, birth_year, nationality
) 
VALUES
('Hermann',   'Hesse',      1877, 'German'),
('Patrick',   'Süskind',    1949, 'German'),
('Umberto',   'Eco',        1932, 'Italian'),
('Douglas',   'Adams',      1952, 'British'),
('Gerhart',   'Hauptmann',  1862, 'German'),
('Max',       'Frisch',     1911, 'Swiss'),
('Jostein',   'Gaarder',    1952, 'Norwegian'),
('Frank',     'Herbert',    1920, 'American'),
('Franz',     'Kafka',      1883, 'Bohemian'),
('Thomas',    'Mann',       1875, 'German'),
('Paulo',     'Coelho',     1947, 'Brazilian'),
('Harper',    'Lee',        1926, 'American');

-- users
INSERT INTO users (first_name, last_name, email, phone, street, city, postal_code, country, latitude, longitude) 
VALUES
(
 'Anna', 'Müller', 'anna.mueller@example.de', '+49 151 11111111', 'Hauptstraße 1', 'Berlin', '10115', 'Germany', 52.520008, 13.404954
),
(
 'Ben', 'Schmidt', 'ben.schmidt@example.de', '+49 152 22222222', 'Goethestraße 12', 'München', '80336', 'Germany', 48.135125, 11.581981
),
(
 'Clara', 'Fischer', 'clara.fischer@example.de', '+49 153 33333333', 'Schillerplatz 3', 'Hamburg', '20095', 'Germany', 53.550341, 9.992862
),
(
 'David', 'Weber', 'david.weber@example.de', '+49 154 44444444', 'Bahnhofstraße 7', 'Frankfurt', '60329', 'Germany', 50.110922, 8.682127
),
(
 'Eva', 'Wagner', 'eva.wagner@example.de', '+49 155 55555555', 'Mozartstraße 9', 'Stuttgart', '70173', 'Germany', 48.775846, 9.182932
),
(
 'Felix', 'Becker', 'felix.becker@example.de', '+49 156 66666666', 'Rüdesheimer Str. 5', 'Köln', '50667', 'Germany', 50.938361, 6.959974
),
(
 'Greta', 'Hoffmann', 'greta.hoffmann@example.de', '+49 157 77777777', 'Am Markt 2', 'Düsseldorf', '40213', 'Germany', 51.225402, 6.776314
),
(
 'Hans', 'Schäfer', 'hans.schaefer@example.de', '+49 158 88888888', 'Lindenallee 14', 'Leipzig',   '04109', 'Germany', 51.339695, 12.373075
),
(
 'Ida', 'Koch', 'ida.koch@example.de', '+49 159 99999999', 'Friedrichstraße 22', 'Dresden',   '01067', 'Germany', 51.050409, 13.737262
),
(
 'Jonas', 'Richter', 'jonas.richter@example.de', '+49 160 10101010', 'Parkstraße 8', 'Bremen', '28195', 'Germany', 53.079296, 8.801694
),
(
 'Katja', 'Klein', 'katja.klein@example.de', '+49 161 11111112', 'Bergstraße 19', 'Hannover', '30159', 'Germany', 52.374478, 9.738553
),
(
 'Lars', 'Wolf', 'lars.wolf@example.de', '+49 162 22222223', 'Seestraße 6', 'Nürnberg', '90402', 'Germany', 49.452030, 11.076750
);

-- books
INSERT INTO books (isbn, title, author, author_id, publisher_id, genre_id, language_id, year_published, description)
VALUES
(
 '978-3-518-41404-0', 'Steppenwolf', 'Hermann Hesse', 1, 1, 1, 1, 1927, 'A German literary classic exploring alienation, identity, and the duality of human nature.'
),
(
 '978-3-423-13522-3', 'Perfume: The Story of a Murderer', 'Patrick Süskind', 2, 7, 1, 1, 1985, 'A darkly obsessive tale of a murderer in 18th-century France driven by an extraordinary sense of smell.'
),
(
 '978-3-499-22765-5', 'The Name of the Rose', 'Umberto Eco', 3, 3, 3, 1, 1986, 'A medieval monastery mystery steeped in symbolism, philosophy, and theological intrigue.'
),
(
 '978-0-7432-7356-5', 'The Hitchhiker''s Guide to the Galaxy', 'Douglas Adams', 4, 5, 2, 2, 1979, 'A wildly comic science fiction adventure following the accidental destruction of Earth.'
),
(
 '978-3-257-06401-1', 'Bahnwärter Thiel', 'Gerhart Hauptmann', 5, 6, 8, 1, 1888, 'A German novella exploring guilt, fate, and the overwhelming force of nature.'
),
(
 '978-3-446-20387-6', 'Homo Faber', 'Max Frisch', 6, 6, 1, 1, 1957, 'A rationalist engineer confronts fate and emotion in this landmark of modern German-language literature.'
),
(
 '978-3-10-397077-8', 'Sophie''s World', 'Jostein Gaarder', 7, 8, 5, 1, 1993, 'A history of Western philosophy told as a gripping coming-of-age novel.'
),
(
 '978-3-453-31628-0', 'Dune', 'Frank Herbert', 8, 7, 2, 1, 2019, 'An epic science fiction saga of power, religion, and ecology set on a desert planet.'
),
(
 '978-3-596-29752-4', 'The Metamorphosis', 'Franz Kafka', 9, 7, 1, 1, 1915, 'Kafka at his most iconic — a man wakes up transformed into an insect in this unsettling masterpiece.'
),
(
 '978-3-423-21190-4', 'Buddenbrooks', 'Thomas Mann', 10, 7, 8, 1, 1901, 'A sweeping family saga tracing the decline of a wealthy merchant dynasty over four generations.'
),
(
 '978-3-8321-6065-0', 'The Alchemist', 'Paulo Coelho', 11, 7, 1, 1, 1993, 'A philosophical parable about following your dreams and discovering your personal destiny.'
),
(
 '978-0-06-112008-4', 'To Kill a Mockingbird', 'Harper Lee', 12, 5, 1, 2, 1960, 'A landmark American novel confronting racial injustice and moral courage in the Deep South.'
);

-- M:N book_authors befüllen
INSERT INTO book_authors (book_id, author_id)
SELECT b.book_id, b.author_id FROM books b WHERE b.author_id IS NOT NULL;

-- book_copies
INSERT INTO book_copies
(
    book_id,
    owner_id,
    condition_id,
    max_loan_days,
    allow_post,
    pickup_address,
    pickup_latitude,
    pickup_longitude,
    is_available
)
VALUES
(1, 1, 2, 14, FALSE, 'Hauptstraße 1, 10115 Berlin', 52.520008, 13.404954, TRUE),
(2, 1, 2, 14, FALSE, 'Hauptstraße 1, 10115 Berlin', 52.520008, 13.404954, TRUE),
(2, 2, 3, 21, TRUE, 'Goethestraße 12, 80336 München', 48.135125, 11.581981, TRUE),
(3, 3, 1, 14, FALSE, 'Schillerplatz 3, 20095 Hamburg', 53.550341, 9.992862, TRUE),
(4, 4, 4, 28, TRUE, 'Bahnhofstraße 7, 60329 Frankfurt', 50.110922, 8.682127, FALSE),
(5, 5, 2, 14, FALSE, 'Mozartstraße 9, 70173 Stuttgart', 48.775846, 9.182932, TRUE),
(6, 6, 3, 14, TRUE, 'Rüdesheimer Str. 5, 50667 Köln', 50.938361, 6.959974, TRUE),
(7, 7, 1, 21, FALSE, 'Am Markt 2, 40213 Düsseldorf', 51.225402, 6.776314, TRUE),
(8, 8, 2, 14, TRUE, 'Lindenallee 14, 04109 Leipzig', 51.339695, 12.373075, FALSE),
(9, 9, 5, 14, FALSE, 'Friedrichstraße 22, 01067 Dresden', 51.050409, 13.737262, TRUE),
(10, 10, 3, 28, TRUE, 'Parkstraße 8, 28195 Bremen', 53.079296, 8.801694, TRUE),
(11, 11, 2, 14, FALSE, 'Bergstraße 19, 30159 Hannover', 52.374478, 9.738553, TRUE),
(12, 12, 1, 21, TRUE, 'Seestraße 6, 90402 Nürnberg', 49.452030, 11.076750, TRUE);


-- time_slots
INSERT INTO time_slots
(
    copy_id,
    day_of_week,
    start_time,
    end_time
)
VALUES
(1, 1, '09:00', '12:00'),
(1, 3, '14:00', '17:00'),  -- Exemplar 1 hat jetzt 2 Zeitslots
(2, 2, '14:00', '17:00'),
(3, 3, '10:00', '13:00'),
(4, 4, '15:00', '18:00'),
(5, 5, '09:00', '11:00'),
(6, 6, '11:00', '14:00'),
(7, 0, '10:00', '15:00'),
(8, 1, '16:00', '19:00'),
(9, 2, '08:00', '10:00'),
(10, 3, '13:00', '16:00'),
(11, 4, '17:00', '20:00'),
(12, 5, '09:00', '12:00'),
(12, 0, '10:00', '13:00'); -- Exemplar 12 hat jetzt 2 Zeitslots

-- loans
INSERT INTO loans
(
    copy_id,
    borrower_id,
    slot_id,
    loaned_at,
    due_date,
    returned_at,
    is_via_post,
    status
)
VALUES
(1, 2, 1, '2024-01-10', '2024-01-24', '2024-01-22', FALSE, 'returned'),
(2, 3, 2, '2024-02-05', '2024-02-26', '2024-02-24', TRUE, 'returned'),
(3, 4, 3, '2024-03-01', '2024-03-15', '2024-03-14', FALSE, 'returned'),
(5, 6, 5, '2024-04-10', '2024-04-24', '2024-04-23', FALSE, 'returned'),
(6, 7, 6, '2024-05-15', '2024-05-29', '2024-05-30', FALSE, 'returned'),
(7, 8, 7, '2024-06-01', '2024-06-22', NULL, FALSE, 'overdue'),
(9, 10, 9, '2024-07-20', '2024-08-03', '2024-08-01', FALSE, 'returned'),
(10, 1, 10, '2024-08-05', '2024-09-02', NULL, TRUE, 'active'),
(11, 2, 11, '2024-08-20', '2024-09-03', NULL, FALSE, 'active'),
(12, 3, 12, '2024-09-01', '2024-09-22', NULL, TRUE, 'active'),
(1, 4, 1, '2024-09-10', '2024-09-24', NULL, FALSE, 'cancelled'),
(3, 5, 3, '2024-10-01', '2024-10-15', NULL, FALSE, 'active');


-- ratings
INSERT INTO ratings
(
    loan_id,
    reviewer_id,
    book_id,
    score,
    comment
)
VALUES
(1, 2, 1, 5, 'Absolutes Meisterwerk, sehr gerne weiterempfohlen!'),
(2, 3, 2, 4, 'Fesselnd und gut geschrieben, toller Zustand des Buches.'),
(3, 4, 3, 5, 'Spannend von Anfang bis Ende – ein Genuss!'),
(4, 6, 5, 3, 'Interessant, aber etwas langatmig an manchen Stellen.'),
(5, 7, 6, 4, 'Sehr philosophisch, regt zum Nachdenken an.'),
(7, 10, 9, 4, 'Kafka in Bestform – kurz aber intensiv.'),
(9, 1, 11, 5, 'Wunderschöne Geschichte, absolut lesenswert.'),
(10, 2, 10, 4, 'Großartiger Klassiker, gut erhalten.'),
(11, 3, 12, 5, 'Bewegender Roman, gehört in jedes Bücherregal.'),
(12, 5, 3, 4, 'Tolle Lektüre, Buch war in sehr gutem Zustand.');

-- messages
INSERT INTO messages
(
    sender_id,
    receiver_id,
    copy_id,
    subject,
    body,
    is_read
)
VALUES
(2, 1, 1, 'Anfrage: Der Steppenwolf', 'Hallo Anna, ist das Buch noch verfügbar? Ich würde es gerne ausleihen.', TRUE),
(1, 2, 1, 'Re: Anfrage: Der Steppenwolf', 'Hallo Ben, ja klar! Du kannst es nächsten Montag abholen.', TRUE),
(3, 2, 2, 'Buchzustand Das Parfum', 'Hi Ben, wie ist der aktuelle Zustand des Buches?', FALSE),
(4, 3, 3, 'Abholung Der Name der Rose', 'Wann kann ich das Buch abholen?', TRUE),
(5, 4, 4, 'Versand möglich?', 'Hi David, kannst du das Buch auch per Post schicken?', FALSE),
(6, 5, 5, 'Verlängerung möglich?', 'Hallo Eva, kann ich die Leihfrist um eine Woche verlängern?', TRUE),
(7, 6, 6, 'Danke für das Buch', 'Hallo Felix, das Buch war super. Vielen Dank!', TRUE),
(8, 7, 7, 'Sofies Welt – Verfügbarkeit', 'Ist das Buch nächste Woche verfügbar?', FALSE),
(9, 8, 8, 'Dune – Rückgabe', 'Hi Hans, ich gebe das Buch übermorgen zurück. Passt das?', TRUE),
(10, 9, 9, 'Buchempfehlung', 'Hallo Ida, die Verwandlung war wirklich beeindruckend!', FALSE),
(11, 10, 10, 'Leihfrist Buddenbrooks', 'Guten Tag Jonas, reichen mir 4 Wochen Leihzeit?', TRUE),
(12, 1, 11, 'Abholung in Hannover', 'Hallo Katja, wann kann ich den Alchimisten abholen?', FALSE);

-- wishlist
INSERT INTO wishlist
(
    user_id,
    book_id
)
VALUES
(1, 4),
(1, 8),
(2, 3),
(2, 9),
(3, 1),
(4, 2),
(5, 6),
(6, 7),
(7, 10),
(8, 11),
(9, 12),
(10, 5),
(11, 4),
(12, 1);
