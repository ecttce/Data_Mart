# Buchtausch App – Datenbankimplementierung

## Projektbeschreibung

Dieses Repository enthält die vollständige PostgreSQL-Datenbankimplementierung für eine **Buchtausch-App** – eine Plattform, auf der Nutzer Bücher kostenlos untereinander ausleihen können. Die Datenbank wurde in der dritten Normalform (3NF) modelliert und umfasst 13 Tabellen, 22 automatisierte Testfälle sowie Trigger für Geschäftslogik.

---

## Datenbankstruktur

### Tabellen (14 gesamt)

| Tabelle | Beschreibung |
|---|---|
| `genres` | Buchgenres (Lookup) |
| `languages` | Sprachen (Lookup) |
| `publishers` | Verlage (Lookup) |
| `book_conditions` | Buchzustände (Lookup) |
| `authors` | Autoren (NEU: eigene Tabelle für bessere 3NF) |
| `users` | Nutzer der Plattform |
| `books` | Bücher (mit FK auf author_id) |
| `book_authors` | M:N-Beziehung Bücher ↔ Autoren |
| `book_copies` | Physische Exemplare im Besitz von Nutzern |
| `time_slots` | Abholzeiträume pro Exemplar |
| `loans` | Ausleihen (ternäre Beziehung) |
| `ratings` | Bewertungen nach Ausleihe |
| `messages` | Nachrichten zwischen Nutzern (Self-Join) |
| `wishlist` | Wunschliste (M:N Nutzer ↔ Bücher) |

### Kennzahlen

| Kennzahl | Wert |
|---|---|
| Tabellen gesamt | 14 |
| Datensätze gesamt | ~165 |
| Fremdschlüsselbeziehungen | 18 |
| Ternäre Beziehungen | 3 |
| Trigger | 2 |
| Indizes | 12 |
| Testfälle | 22 |
| DBMS | PostgreSQL 14+ |
| Normalisierung | 3NF |

---

## Installationsanleitung

### Voraussetzungen

- PostgreSQL 14 oder höher
- psql-Client oder pgAdmin 4
- Alternativ Docker

### Schritt-für-Schritt

```bash
# 1. Datenbank erstellen
createdb buchtausch

# 2. SQL-Datei ausführen
cd DB                                           # Wenn im Projekt-Root-Folder, ansonsten absolute Path
psql -d buchtausch -f 01_CREATE_TABLES.sql
psql -d buchtausch -f 02_CREATE_DUMMY_DATA.sql

# 3. Verbindung prüfen
psql -d buchtausch -c "\dt"
```

### Alternativ mit pgAdmin

1. pgAdmin öffnen → Rechtsklick auf „Databases" → „Create Database"
2. Name: `buchtausch`
3. Query Tool öffnen → `01_CREATE_TABLES.sql`, danach `02_CREATE_DUMMY_DATA.sql.sql` öffnen → F5 / Ausführen

### Alternativ mit Docker
1. `.env_template` duplizieren und in `.env` umbennen. Danach die Placeholder ausfüllen.
2. Shell ausführen
```bash
docker-compose up       # Wenn im Projekt-Root-Folder, ansonsten cd in Projekt-Folder
```
3. `docker-compose.yml` erstellt die Datenbank automatisch und führt die dazugehörigen `.sql`-Statements aus.

---

## Projektstruktur

```
DataMart/
├── 1_Konzeptionsphase              # Vollständige 1.Phase
├── 2_Erarbeitungsphase             # Vollständige 2.Phase
├── 3_Finalisierungsphase           # Vollständige 3.Phase
├── DB                              # Sql-Statements
    ├── 01_CREATE_TABLES.sql
    ├── 02_CREATE_DUMMY_DATA.sql
    ├── 03_TEST.sql                 # Testfälle
    └── 04_EXPLAINS.sql              # Explains zur Performance
├── Screenshots                     # Ordner mit Screenshots
├── .env_template
├── .gitignore
├── docker-compose.yml              # Datenbank-Setup mit Docker 
└── README.md
```
