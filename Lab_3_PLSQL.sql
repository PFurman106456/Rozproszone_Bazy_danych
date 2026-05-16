--- Zadanie 1 ---

SET SERVEROUTPUT ON;

DECLARE
  v_kursanci   NUMBER;
  v_kursy      NUMBER;
  v_wykladowcy NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_kursanci   FROM kursanci;
  SELECT COUNT(*) INTO v_kursy      FROM kursy;
  SELECT COUNT(*) INTO v_wykladowcy FROM wykladowcy;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: '   || v_kursanci);
  DBMS_OUTPUT.PUT_LINE('Liczba kursów: '      || v_kursy);
  DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || v_wykladowcy);
END;
/

--- Zadanie 2 ---

DECLARE
  v_suma NUMBER;
BEGIN
  SELECT SUM(r.cena)
  INTO v_suma
  FROM umowy u
  JOIN kursy k     ON u.kurs_id    = k.kurs_id
  JOIN rodzaje r   ON k.rodzaj_id  = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_suma || ' zł');
END;
/

--- Zadanie 3 ---

DECLARE
  v_miasto VARCHAR2(30);
  v_liczba NUMBER;
BEGIN
  v_miasto := 'BYDGOSZCZ';

  SELECT COUNT(*)
  INTO v_liczba
  FROM umowy
  WHERE miasto = v_miasto;

  IF v_liczba = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta' || v_liczba);
  ELSIF v_liczba < 50 THEN
    DBMS_OUTPUT.PUT_LINE('Mała liczba umów' || v_liczba);
  ELSIF v_liczba <= 100 THEN
    DBMS_OUTPUT.PUT_LINE('Średnia liczba umów' || v_liczba);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Duża liczba umów' || v_liczba);
  END IF;
END;
/

--- Zadanie 4 ---

BEGIN
  FOR r IN (
    SELECT k.kurs_id,
           ro.nazwa AS nazwa_rodzaju,
           ro.godz,
           ro.cena,
           w.imie || ' ' || w.nazwisko AS prowadzacy
    FROM kursy k
    JOIN rodzaje    ro ON k.rodzaj_id     = ro.rodzaj_id
    JOIN wykladowcy w  ON k.wykladowca_id = w.wykladowca_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa_rodzaju || ', ' || r.godz || 'h, ' || r.cena || ' zł, prowadzący: ' || r.prowadzacy);
  END LOOP;
END;
/

--- Zadanie 5 ---

CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2)
AS
  v_liczba  NUMBER;
  v_suma    NUMBER;
  v_srednia NUMBER;
BEGIN
  SELECT COUNT(*), SUM(r.cena), AVG(r.cena)
  INTO v_liczba, v_suma, v_srednia
  FROM umowy u
  JOIN kursy   k ON u.kurs_id   = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = p_miasto;

  DBMS_OUTPUT.PUT_LINE('Raport dla miasta: '     || p_miasto);
  DBMS_OUTPUT.PUT_LINE('Liczba umów: '           || v_liczba);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: '   || v_suma || ' zł');
  DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(v_srednia, 2) || ' zł');
END;
/

BEGIN
  raport_umow_miasto('BYDGOSZCZ');
END;
/

--- Zadanie 6 ---

CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER
AS
  v_cena NUMBER;
BEGIN
  SELECT r.cena
  INTO v_cena
  FROM kursy k
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE k.kurs_id = p_kurs_id;

  RETURN v_cena;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

DECLARE
  v_cena NUMBER;
BEGIN
  v_cena := wartosc_kursu(7);
  DBMS_OUTPUT.PUT_LINE('Cena kursu: ' || v_cena);
END;
/

--- Zadanie 7 ---
-- wariant 1 ---
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER)
AS
  v_imie     kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko
  INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE kursant_id = p_kursant_id;

  DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/
--- wariant 2 ---

CREATE OR REPLACE PROCEDURE pokaz_kursanta_nazwisko(p_nazwisko IN VARCHAR2)
AS
  v_imie     kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko
  INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE nazwisko = p_nazwisko;

  DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o nazwisku: ' || p_nazwisko);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Znaleziono więcej niż jednego kursanta o nazwisku: ' || p_nazwisko);
END;
/

--- Zadanie 8 ---

DECLARE
  CURSOR c_umowy IS
    SELECT u.umowa_id,
           k.imie || ' ' || k.nazwisko AS kursant,
           r.nazwa                     AS kurs,
           r.cena
    FROM umowy u
    JOIN kursanci  k  ON u.kursant_id = k.kursant_id
    JOIN kursy     ks ON u.kurs_id    = ks.kurs_id
    JOIN rodzaje   r  ON ks.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

  v_wiersz c_umowy%ROWTYPE;
BEGIN
  OPEN c_umowy;

  LOOP
    FETCH c_umowy INTO v_wiersz;
    EXIT WHEN c_umowy%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Umowa ' || v_wiersz.umowa_id || ' | ' || v_wiersz.kursant || ' | ' || v_wiersz.kurs || ' | ' || v_wiersz.cena || ' zł');
  END LOOP;

  CLOSE c_umowy;
END;
/
--- Zadanie 9 ---



--- Zadanie 10 ---

