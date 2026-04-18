--- Tworzenie linku do baza11b ---

CREATE DATABASE LINK filia
  CONNECT TO RBDN1_ST1
  IDENTIFIED BY start123
  USING 'baza11b';
  
  
--- Zadanie 4 ---

SELECT * FROM kursanci@filia;


--- Zadanie 5 ---

CREATE SYNONYM kursanciSiedziba FOR kursanci;
CREATE SYNONYM kursySiedziba FOR kursy;
CREATE SYNONYM rodzajeSiedziba FOR rodzaje;
CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;

CREATE SYNONYM kursanciFilia FOR kursanci@dblinkfilia;
CREATE SYNONYM kursyFilia FOR kursy@dblinkfilia;
CREATE SYNONYM rodzajeFilia FOR rodzaje@dblinkfilia;
CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkfilia;


--- Zadanie 6 Tworzenie view ---

CREATE VIEW kursanciAll AS
SELECT imie, nazwisko FROM kursanciSiedziba
UNION
SELECT imie, nazwisko FROM kursanciFilia;

-- Dla wykladowcow ---

CREATE VIEW wykladowcyAll AS
SELECT imie, nazwisko FROM wykladowcySiedziba
UNION
SELECT imie, nazwisko FROM wykladowcyfilia


-- Zadanie 7 -- Ale tylko dla 1 tabeli -- Brak umow w bd filia

SELECT kursySiedziba.kurs_id, wykladowcySiedziba.imie, wykladowcySiedziba.nazwisko, COUNT(umowy.umowa_id) AS IloscUmow
FROM kursySiedziba
LEFT JOIN umowy ON umowy.kurs_id = kursySiedziba.kurs_id
LEFT JOIN wykladowcySiedziba ON wykladowcySiedziba.wykladowca_id = kursySiedziba.wykladowca_id
GROUP BY kursySiedziba.kurs_id, wykladowcySiedziba.imie, wykladowcySiedziba.nazwisko;


-- Zadanie 8 -- 

SELECT 
    r.nazwa                             AS nazwa_kursu,
    COUNT(u.kursant_id) * r.cena        AS przychod
FROM kursy k
JOIN rodzaje r   ON k.rodzaj_id = r.rodzaj_id
JOIN umowy u     ON k.kurs_id   = u.kurs_id
GROUP BY r.nazwa, r.cena;

--- Zadanie 9 -- 

SELECT 
    r.nazwa                                              AS nazwa_kursu,
    r.godz * w.stawka * COUNT(u.kursant_id)              AS koszt_wykladowcy
FROM kursy k
JOIN rodzaje r    ON k.rodzaj_id    = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
JOIN umowy u      ON k.kurs_id      = u.kurs_id
GROUP BY r.nazwa, r.godz, w.stawka;


-- Zadanie 10 -- 

SELECT 
    r.nazwa                                                          AS nazwa_kursu,
    COUNT(u.kursant_id) * r.cena 
        - r.godz * w.stawka * COUNT(u.kursant_id)                   AS zysk
FROM kursy k
JOIN rodzaje r    ON k.rodzaj_id    = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
JOIN umowy u      ON k.kurs_id      = u.kurs_id
GROUP BY r.nazwa, r.cena, r.godz, w.stawka;


-- Zadanie 11 -- 

SELECT SUM(zysk) AS laczny_zysk
FROM (
    SELECT 
        COUNT(u.kursant_id) * (r.cena - r.godz * w.stawka) AS zysk
    FROM kursy k
    JOIN rodzaje r    ON k.rodzaj_id    = r.rodzaj_id
    JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
    JOIN umowy u      ON k.kurs_id      = u.kurs_id
    GROUP BY r.nazwa, r.cena, r.godz, w.stawka
);