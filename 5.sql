-- zad1
--Stworzyć blok anonimowy wypisujący zmienną numer_max równą maksymalnemu
--numerowi Departamentu i dodaj do tabeli departamenty – departament z numerem o
--10 wiekszym, typ pola dla zmiennej z nazwą nowego departamentu (zainicjować na
--EDUCATION) ustawić taki jak dla pola department_name w tabeli (%TYPE)

DECLARE
    v_max_id       departments.department_id%TYPE;
    v_dept_name    departments.department_name%TYPE := 'EDUCATION';
    v_new_id       departments.department_id%TYPE;
BEGIN
    SELECT MAX(department_id) INTO v_max_id FROM departments;
    v_new_id := v_max_id + 10;

    INSERT INTO departments (department_id, department_name)
    VALUES (v_new_id, v_dept_name);

    DBMS_OUTPUT.PUT_LINE('Dodano dział: ' || v_dept_name || ', ID: ' || v_new_id);
END;
/

-- zad2
--Do poprzedniego skryptu dodaj instrukcje zmieniającą location_id (3000) dla
--dodanego departamentu

DECLARE
    v_max_id       departments.department_id%TYPE;
    v_new_id       departments.department_id%TYPE;
    v_new_name     departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id) INTO v_max_id FROM departments;
    v_new_id := v_max_id + 10;

    INSERT INTO departments (department_id, department_name)
    VALUES (v_new_id, v_new_name);

    UPDATE departments
    SET location_id = 3000
    WHERE department_id = v_new_id;

    DBMS_OUTPUT.PUT_LINE('Dodano dział i ustawiono location_id = 3000.');
END;
/
-- zad3
-- Stwórz tabelę nowa z jednym polem typu varchar a następnie wpisz do niej za
--pomocą pętli liczby od 1 do 10 bez liczb 4 i 6

CREATE TABLE nowa (
    dana VARCHAR2(10)
);
BEGIN
    FOR i IN 1..10 LOOP
        IF i NOT IN (4, 6) THEN
            INSERT INTO nowa (dana) VALUES (TO_CHAR(i));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Wstawiono dane do tabeli NOWA.');
END;
/

-- zad4
--Wyciągnąć informacje z tabeli countries do jednej zmiennej (%ROWTYPE) dla kraju o
--identyfikatorze ‘CA’. Wypisać nazwę i region_id na ekran

DECLARE
    v_country_row countries%ROWTYPE;
BEGIN
    SELECT * INTO v_country_row FROM countries WHERE country_id = 'CA';

    DBMS_OUTPUT.PUT_LINE('Kraj: ' || v_country_row.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || v_country_row.region_id);
END;
/
-- zad5
--Zadeklaruj kursor jako wynagrodzenie, nazwisko dla departamentu o numerze 50. Dla
--elementów kursora wypisać na ekran, jeśli wynagrodzenie jest wyższe niż 3100:
--nazwisko osoby i tekst ‘nie dawać podwyżki’ w przeciwnym przypadku: nazwisko +
--‘dać podwyżkę’

DECLARE
    CURSOR cur_emp IS
        SELECT last_name, salary FROM employees WHERE department_id = 50;
BEGIN
    FOR r IN cur_emp LOOP
        IF r.salary <= 3100 THEN
            DBMS_OUTPUT.PUT_LINE(r.last_name || ': można dać podwyżkę');
        ELSE
            DBMS_OUTPUT.PUT_LINE(r.last_name || ': NIE dawać podwyżki');
        END IF;
    END LOOP;
END;
/
-- zad6 
--Zadeklarować kursor zwracający zarobki imię i nazwisko pracownika z parametrami,
--gdzie pierwsze dwa parametry określają widełki zarobków a trzeci część imienia
--pracownika. Wypisać na ekran pracowników:
-- a z widełkami 1000- 5000 z częścią imienia a (może być również A)
DECLARE
    v_min NUMBER := 1000;
    v_max NUMBER := 5000;
    v_fragment VARCHAR2(20) := 'a';

    CURSOR c_emps(p_min NUMBER, p_max NUMBER, p_frag VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min AND p_max
          AND UPPER(first_name) LIKE '%' || UPPER(p_frag) || '%';

BEGIN
    FOR emp IN c_emps(v_min, v_max, v_fragment) LOOP
        DBMS_OUTPUT.PUT_LINE('Imię i nazwisko: ' || emp.first_name || ' ' || emp.last_name || ', Pensja: ' || emp.salary);
    END LOOP;
END;
/
-- b z widełkami 5000-20000 z częścią imienia u (może być również U)
DECLARE
    v_min NUMBER := 1000;
    v_max NUMBER := 5000;
    v_part VARCHAR2(20) := 'u';

    CURSOR emp_cursor(p1 NUMBER, p2 NUMBER, frag VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p1 AND p2
          AND INSTR(UPPER(first_name), UPPER(frag)) > 0;

BEGIN
    FOR emp_rec IN emp_cursor(v_min, v_max, v_part) LOOP
        DBMS_OUTPUT.PUT_LINE('Pracownik: ' || emp_rec.first_name || ' ' || emp_rec.last_name || ', Zarobki: ' || emp_rec.salary);
    END LOOP;
END;
/
-- zad9 Stwórz procedury:
-- a dodającą wiersz do tabeli Jobs – z dwoma parametrami wejściowymi
--określającymi Job_id, Job_title, przetestuj działanie wrzuć wyjątki – co
--najmniej when others
CREATE OR REPLACE PROCEDURE dodaj_zawod (
    p_id    JOBS.job_id%TYPE,
    p_tytul JOBS.job_title%TYPE
) AS
BEGIN
    INSERT INTO JOBS (job_id, job_title)
    VALUES (p_id, p_tytul);

    DBMS_OUTPUT.PUT_LINE('Zawód dodany: ' || p_tytul);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd przy dodawaniu: ' || SQLERRM);
END;
/

-- Test
EXEC dodaj_zawod('NEW_JOB1', 'PL/SQL Tester');

-- b modyfikującą title w tabeli Jobs – z dwoma parametrami id dla którego ma być
--modyfikacja oraz nową wartość dla Job_title – przetestować działanie, dodać
--swój wyjątek dla no Jobs updated – najpierw sprawdzić numer błędu
CREATE OR REPLACE PROCEDURE zmodyfikuj_zawod (
    p_id JOBS.job_id%TYPE,
    p_nazwa JOBS.job_title%TYPE
) AS
    v_count NUMBER;
BEGIN
    UPDATE JOBS
    SET job_title = p_nazwa
    WHERE job_id = p_id;

    v_count := SQL%ROWCOUNT;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono zawodu do zmiany.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- Test
EXEC zmodyfikuj_zawod('NEW_JOB1', 'PL/SQL Dev');

-- c usuwającą wiersz z tabeli Jobs o podanym Job_id– przetestować działanie,
--dodaj wyjątek dla no Jobs deleted

CREATE OR REPLACE PROCEDURE usun_zawod (
    p_id JOBS.job_id%TYPE
) AS
    v_cnt NUMBER;
BEGIN
    DELETE FROM JOBS WHERE job_id = p_id;
    v_cnt := SQL%ROWCOUNT;

    IF v_cnt = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Zawód nie istnieje.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zawód został usunięty.');
    END IF;
END;
/

-- Test
EXEC usun_zawod('NEW_JOB1');


-- d Wyciągającą zarobki i nazwisko (parametry zwracane przez procedurę) z
--tabeli employees dla pracownika o przekazanym jako parametr id

CREATE OR REPLACE PROCEDURE dane_pracownika (
    p_id        EMPLOYEES.employee_id%TYPE,
    p_nazwisko  OUT EMPLOYEES.last_name%TYPE,
    p_zarobki   OUT EMPLOYEES.salary%TYPE
) AS
BEGIN
    SELECT last_name, salary INTO p_nazwisko, p_zarobki
    FROM employees
    WHERE employee_id = p_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_nazwisko := 'Brak danych';
        p_zarobki := NULL;
END;
/

-- Test
DECLARE
    ln EMPLOYEES.last_name%TYPE;
    sal EMPLOYEES.salary%TYPE;
BEGIN
    dane_pracownika(100, ln, sal);
    DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || ln || ', Wynagrodzenie: ' || TO_CHAR(sal));
END;
/

-- e dodającą do tabeli employees wiersz – większość parametrów ustawić na
--domyślne (id poprzez sekwencję), stworzyć wyjątek jeśli wynagrodzenie
--dodawanego pracownika jest wyższe niż 20000
CREATE SEQUENCE EMPLOYEES_SEQ
  START WITH 1000
  INCREMENT BY 1
  NOCACHE;
  
  
  CREATE OR REPLACE PROCEDURE dodaj_nowego_pracownika (
    p_imie     EMPLOYEES.first_name%TYPE,
    p_nazwisko EMPLOYEES.last_name%TYPE,
    p_zarobki  EMPLOYEES.salary%TYPE,
    p_zawod    EMPLOYEES.job_id%TYPE,
    p_dzial    EMPLOYEES.department_id%TYPE
) AS
BEGIN
    IF p_zarobki > 20000 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Zarobki są zbyt wysokie.');
    END IF;

    INSERT INTO EMPLOYEES (
        employee_id, first_name, last_name, salary, job_id, department_id
    ) VALUES (
        EMPLOYEES_SEQ.NEXTVAL, p_imie, p_nazwisko, p_zarobki, p_zawod, p_dzial
    );

    DBMS_OUTPUT.PUT_LINE('Nowy pracownik: ' || p_imie || ' ' || p_nazwisko);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- Test
EXEC dodaj_nowego_pracownika('Anna', 'Nowak', 3500, 'IT_PROG', 60);


