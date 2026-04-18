-- Zadanie 1 -- 

CREATE MATERIALIZED VIEW REP_wykladowcy
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT * FROM wykladowcy@dblinkfilia;


-- Zadanie 2 -- 

INSERT INTO wykladowcy@dblinkfilia (wykladowca_id, imie, nazwisko, stawka)
VALUES (116, 'NOWA', 'OSOBA', 110);
COMMIT;

-- Zadanie 3 -- 

SELECT * FROM REP_wykladowcy;

-- Zadanie 4 --

EXECUTE DBMS_MVIEW.REFRESH('REP_wykladowcy', 'C');


-- Zadanie 5 --

SELECT * FROM REP_wykladowcy;

-- Zadanie 6 -- 


CREATE MATERIALIZED VIEW REP_godz_wykladowcy_godziny
BUILD DEFERRED
REFRESH COMPLETE
ON DEMAND
START WITH LAST_DAY(SYSDATE)
NEXT LAST_DAY(SYSDATE) + 1/24
AS
SELECT 
    w.imie,
    w.nazwisko,
    SUM(r.godz)  AS laczna_liczba_godzin
FROM wykladowcy@dblinkfilia w
JOIN kursy@dblinkfilia k   ON w.wykladowca_id = k.wykladowca_id
JOIN rodzaje@dblinkfilia r ON k.rodzaj_id     = r.rodzaj_id
GROUP BY w.imie, w.nazwisko;

-- Zadanie 7 --

CREATE MATERIALIZED VIEW REP_kursy
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
START WITH SYSDATE
NEXT SYSDATE + 7
AS
SELECT 
    r.nazwa                        AS nazwa_kursu,
    w.imie || ' ' || w.nazwisko    AS prowadzacy,
    r.godz                         AS liczba_godzin,
    r.cena                         AS oplata
FROM kursy@dblinkfilia k
JOIN rodzaje@dblinkfilia r    ON k.rodzaj_id    = r.rodzaj_id
JOIN wykladowcy@dblinkfilia w ON k.wykladowca_id = w.wykladowca_id;

-- Zadanie 8 --


CREATE VIEW wszystkie_kursy AS
SELECT 
    r.nazwa                        AS nazwa_kursu,
    w.imie || ' ' || w.nazwisko    AS prowadzacy,
    r.godz                         AS liczba_godzin,
    r.cena                         AS oplata,
    'SIEDZIBA'                     AS zrodlo
FROM kursy k
JOIN rodzaje r    ON k.rodzaj_id    = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id

UNION ALL

SELECT 
    nazwa_kursu,
    prowadzacy,
    liczba_godzin,
    oplata,
    'FILIA'                        AS zrodlo
FROM REP_kursy;

-- Zadanie 9 -- 

SELECT name, refresh_method, last_refresh
FROM user_snapshots;