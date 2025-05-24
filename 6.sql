-- Funkcje 
-- zad1 
--Zwracającą nazwę pracy dla podanego parametru id, dodaj wyjątek, jeśli taka praca nie
--istnieje

CREATE OR REPLACE FUNCTION f_get_job_title (
    job_id_in JOBS.job_id%TYPE
) RETURN JOBS.job_title%TYPE
IS
    job_title_out JOBS.job_title%TYPE;
BEGIN
    SELECT job_title INTO job_title_out
    FROM jobs
    WHERE job_id = job_id_in;

    RETURN job_title_out;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono job_id: ' || job_id_in);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, SQLERRM);
END;
/

-- test
SELECT f_get_job_title('IT_PROG') AS job_title FROM dual;

-- zad2
--zwracającą roczne zarobki (wynagrodzenie 12-to miesięczne plus premia jako
--wynagrodzenie * commission_pct) dla pracownika o podanym id

CREATE OR REPLACE FUNCTION get_annual_salary (
    p_emp_id EMPLOYEES.employee_id%TYPE
)
RETURN NUMBER
IS
    v_salary       EMPLOYEES.salary%TYPE;
    v_commission   EMPLOYEES.commission_pct%TYPE;
    v_annual       NUMBER;
BEGIN
    SELECT salary, commission_pct
    INTO v_salary, v_commission
    FROM employees
    WHERE employee_id = p_emp_id;

    -- Roczne zarobki = (pensja * 12) + (pensja * commission_pct)
    v_annual := (v_salary * 12) + (v_salary * NVL(v_commission, 0));

    RETURN v_annual;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Nie znaleziono pracownika o ID = ' || p_emp_id);
END;
/

-- test 
SELECT f_annual_salary(178) AS roczne_zarobki FROM dual;

-- zad3
--biorącą w nawias numer kierunkowy z numeru telefonu podanego jako varchar
CREATE OR REPLACE FUNCTION format_phone (
    phone_in VARCHAR2
) RETURN VARCHAR2
IS
    dash_pos NUMBER := INSTR(phone_in, '-');
BEGIN
    IF dash_pos > 0 THEN
        RETURN '(' || SUBSTR(phone_in, 1, dash_pos - 1) || ')-' || SUBSTR(phone_in, dash_pos + 1);
    ELSE
        RETURN phone_in;
    END IF;
END;
/

-- test
SELECT format_phone('22-8889999') AS phone_wrapped FROM dual;

-- zad4
-- Dla podanego w parametrze ciągu znaków zmieniającą pierwszą i ostatnią literę na
--wielką – pozostałe na małe
CREATE OR REPLACE FUNCTION format_name (
    txt VARCHAR2
) RETURN VARCHAR2
IS
    len NUMBER := LENGTH(txt);
BEGIN
    IF len = 0 THEN
        RETURN txt;
    ELSIF len = 1 THEN
        RETURN UPPER(txt);
    ELSIF len = 2 THEN
        RETURN UPPER(txt);
    ELSE
        RETURN UPPER(SUBSTR(txt, 1, 1)) || LOWER(SUBSTR(txt, 2, len - 2)) || UPPER(SUBSTR(txt, len));
    END IF;
END;
/

-- test 
SELECT format_name('hello elo') AS wynik FROM dual;

-- zad5
--Dla podanego peselu - przerabiającą pesel na datę urodzenia w formacie ‘yyyy-mm-dd’
CREATE OR REPLACE FUNCTION pesel_to_date (
    pesel VARCHAR2
) RETURN VARCHAR2
IS
    yy  NUMBER;
    mm  NUMBER;
    dd  NUMBER;
    rok NUMBER;
    miesiac NUMBER;
    baza NUMBER;
BEGIN
    IF LENGTH(pesel) < 6 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Niepełny PESEL');
    END IF;

    yy := TO_NUMBER(SUBSTR(pesel, 1, 2));
    mm := TO_NUMBER(SUBSTR(pesel, 3, 2));
    dd := TO_NUMBER(SUBSTR(pesel, 5, 2));

    CASE 
        WHEN mm BETWEEN 1 AND 12 THEN baza := 1900;
        WHEN mm BETWEEN 21 AND 32 THEN baza := 2000; mm := mm - 20;
        WHEN mm BETWEEN 41 AND 52 THEN baza := 2100; mm := mm - 40;
        WHEN mm BETWEEN 61 AND 72 THEN baza := 2200; mm := mm - 60;
        WHEN mm BETWEEN 81 AND 92 THEN baza := 1800; mm := mm - 80;
        ELSE RAISE_APPLICATION_ERROR(-20002, 'Błędny miesiąc w PESEL');
    END CASE;

    rok := baza + yy;

    RETURN TO_CHAR(TO_DATE(rok || LPAD(mm,2,'0') || LPAD(dd,2,'0'), 'YYYYMMDD'), 'YYYY-MM-DD');
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Błąd PESEL: ' || SQLERRM);
END;
/

-- test
SELECT pesel_to_date('00301904371') AS data_ur FROM dual;

-- zad6
--Zwracającą liczbę pracowników oraz liczbę departamentów które znajdują się w kraju
--podanym jako parametr (nazwa kraju). W przypadku braku kraju - odpowiedni wyjątek
CREATE OR REPLACE FUNCTION f_country_stats (
    name_in COUNTRIES.country_name%TYPE
) RETURN VARCHAR2
IS
    cid COUNTRIES.country_id%TYPE;
    depts NUMBER := 0;
    emps  NUMBER := 0;
BEGIN
    SELECT country_id INTO cid FROM countries WHERE UPPER(country_name) = UPPER(name_in);

    SELECT COUNT(*) INTO depts
    FROM departments d JOIN locations l ON d.location_id = l.location_id
    WHERE l.country_id = cid;

    SELECT COUNT(*) INTO emps
    FROM employees e JOIN departments d ON e.department_id = d.department_id
                     JOIN locations l ON d.location_id = l.location_id
    WHERE l.country_id = cid;

    RETURN 'Pracownicy: ' || emps || ', Działy: ' || depts;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono kraju: ' || name_in);
END;
/

-- test
SELECT f_country_stats('Canada') AS statystyki FROM dual;


-- wyzwalacze
-- zad1
--Stworzyć tabelę archiwum_departamentów (id, nazwa, data_zamknięcia,
--ostatni_manager jako imię i nazwisko). Po usunięciu departamentu dodać odpowiedni
--rekord do tej tabeli

CREATE TABLE archiwum_departamentow (
    dept_id NUMBER,
    nazwa VARCHAR2(100),
    data_zamkniecia DATE,
    ostatni_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER trg_backup_dept
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
    mgr_name VARCHAR2(100);
BEGIN
    BEGIN
        SELECT first_name || ' ' || last_name INTO mgr_name
        FROM employees
        WHERE employee_id = :OLD.manager_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mgr_name := 'BRAK DANYCH';
    END;

    INSERT INTO archiwum_departamentow (dept_id, nazwa, data_zamkniecia, ostatni_manager)
    VALUES (:OLD.department_id, :OLD.department_name, SYSDATE, mgr_name);
END;
/

-- test
DELETE FROM departments WHERE department_name = 'EDUCATION';
SELECT * FROM archiwum_departamentow;

-- zad2
--W razie UPDATE i INSERT na tabeli employees, sprawdzić czy zarobki łapią się w
--widełkach 2000 - 26000. Jeśli nie łapią się - zabronić dodania. Dodać tabelę złodziej(id,
--USER, czas_zmiany), której będą wrzucane logi, jeśli będzie próba dodania, bądź
--zmiany wynagrodzenia poza widełki
CREATE TABLE zlodziej (
    user_name    VARCHAR2(100),
    czas_zmiany  DATE
);

CREATE OR REPLACE TRIGGER trg_validate_salary
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        INSERT INTO zlodziej (user_name, czas_zmiany)
        VALUES (USER, SYSDATE);
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001, 'Zarobki poza zakresem (2000-26000)');
    END IF;
END;
/

-- test (powinien wywołać wyjątek i dopisać do zlodziej)
INSERT INTO employees (
    employee_id, first_name, last_name, salary, job_id, department_id, email, hire_date
)
VALUES (
    1002, 'Tomasz', 'Piotrowski', 25000, 'IT_PROG', 60, 'tpiotrowski2@wp.pl', SYSDATE
);
SELECT * FROM zlodziej;


-- zad3
--Stworzyć sekwencję i wyzwalacz, który będzie odpowiadał za auto_increment w tabeli
--employees.
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE employees_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
            RAISE;
        END IF;
END;
/

CREATE SEQUENCE employees_seq
  START WITH 1000
  INCREMENT BY 1
  NOCACHE;
-- zad4
--Stworzyć wyzwalacz, który zabroni dowolnej operacji na tabeli JOD_GRADES (INSERT,
--UPDATE, DELETE)

CREATE OR REPLACE TRIGGER trg_block_job_grades
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Modyfikacja job_grades zabroniona!');
END;
/

-- test
INSERT INTO job_grades (grade, min_salary, max_salary)
VALUES ('A', 5000, 10000);

-- zad5
--Stworzyć wyzwalacz, który przy próbie zmiany max i min salary w tabeli jobs zostawia
--stare wartości.
CREATE OR REPLACE TRIGGER trg_protect_salary_range
BEFORE UPDATE OF min_salary, max_salary ON jobs
FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
END;
/

-- test 
UPDATE jobs
SET min_salary = 1000
WHERE job_id = 'IT_PROG';

-- paczki
-- zad1
--Składającą się ze stworzonych procedur i funkcji

CREATE OR REPLACE PACKAGE hr_utils_pkg AS

    FUNCTION fetch_job_title (
        job_id_in JOBS.job_id%TYPE
    ) RETURN JOBS.job_title%TYPE;

    PROCEDURE get_employee_info (
        emp_id_in       EMPLOYEES.employee_id%TYPE,
        last_name_out   OUT EMPLOYEES.last_name%TYPE,
        salary_out      OUT EMPLOYEES.salary%TYPE
    );

    FUNCTION compute_annual_salary (
        emp_id_in EMPLOYEES.employee_id%TYPE
    ) RETURN NUMBER;

    FUNCTION format_name (
        input_text VARCHAR2
    ) RETURN VARCHAR2;

    PROCEDURE insert_employee (
        fname EMPLOYEES.first_name%TYPE,
        lname EMPLOYEES.last_name%TYPE,
        sal   EMPLOYEES.salary%TYPE,
        job   EMPLOYEES.job_id%TYPE,
        dept  EMPLOYEES.department_id%TYPE,
        mail  EMPLOYEES.email%TYPE
    );

END hr_utils_pkg;
/

CREATE OR REPLACE PACKAGE BODY hr_utils_pkg AS

    FUNCTION fetch_job_title (
        job_id_in JOBS.job_id%TYPE
    ) RETURN JOBS.job_title%TYPE
    IS
        title JOBS.job_title%TYPE;
    BEGIN
        SELECT job_title INTO title FROM jobs WHERE job_id = job_id_in;
        RETURN title;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Brak job_id: ' || job_id_in);
    END;

    PROCEDURE get_employee_info (
        emp_id_in       EMPLOYEES.employee_id%TYPE,
        last_name_out   OUT EMPLOYEES.last_name%TYPE,
        salary_out      OUT EMPLOYEES.salary%TYPE
    ) IS
    BEGIN
        SELECT last_name, salary
        INTO last_name_out, salary_out
        FROM employees
        WHERE employee_id = emp_id_in;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            last_name_out := 'BRAK';
            salary_out := NULL;
    END;

    FUNCTION compute_annual_salary (
        emp_id_in EMPLOYEES.employee_id%TYPE
    ) RETURN NUMBER
    IS
        base_sal EMPLOYEES.salary%TYPE;
        comm     EMPLOYEES.commission_pct%TYPE;
    BEGIN
        SELECT salary, NVL(commission_pct, 0)
        INTO base_sal, comm
        FROM employees
        WHERE employee_id = emp_id_in;

        RETURN (base_sal * 12) + (base_sal * comm);
    END;

    FUNCTION format_name (
        input_text VARCHAR2
    ) RETURN VARCHAR2
    IS
        len NUMBER := LENGTH(input_text);
    BEGIN
        IF len = 0 THEN
            RETURN input_text;
        ELSIF len = 1 THEN
            RETURN UPPER(input_text);
        ELSE
            RETURN UPPER(SUBSTR(input_text, 1, 1)) ||
                   LOWER(SUBSTR(input_text, 2, len - 2)) ||
                   UPPER(SUBSTR(input_text, len));
        END IF;
    END;

    PROCEDURE insert_employee (
        fname EMPLOYEES.first_name%TYPE,
        lname EMPLOYEES.last_name%TYPE,
        sal   EMPLOYEES.salary%TYPE,
        job   EMPLOYEES.job_id%TYPE,
        dept  EMPLOYEES.department_id%TYPE,
        mail  EMPLOYEES.email%TYPE
    ) IS
    BEGIN
        IF sal > 20000 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Zarobki przekraczają limit: 20000');
        END IF;

        INSERT INTO employees (
            employee_id, first_name, last_name, salary, job_id, department_id, email, hire_date
        ) VALUES (
            employees_seq.NEXTVAL, fname, lname, sal, job, dept, mail, SYSDATE
        );

        DBMS_OUTPUT.PUT_LINE('Dodano: ' || fname || ' ' || lname);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
    END;

END hr_utils_pkg;
/

-- TESTY ZADANIA 1

-- test funkcji fetch_job_title
SELECT hr_utils_pkg.fetch_job_title('IT_PROG') AS job_title FROM dual;

-- test procedury get_employee_info
DECLARE
    v_nazwisko EMPLOYEES.last_name%TYPE;
    v_zarobki  EMPLOYEES.salary%TYPE;
BEGIN
    hr_utils_pkg.get_employee_info(100, v_nazwisko, v_zarobki);
    DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || v_nazwisko || ', Pensja: ' || v_zarobki);
END;
/

-- test funkcji compute_annual_salary
SELECT hr_utils_pkg.compute_annual_salary(100) AS roczne_zarobki FROM dual;

-- test funkcji format_name
SELECT hr_utils_pkg.format_name('janek') AS imie FROM dual;

-- test procedury insert_employee
EXEC hr_utils_pkg.insert_employee('Kasia', 'Nowak', 4500, 'IT_PROG', 60, 'kasia.nowak@example.com');


-- zad2
--Stworzyć paczkę z procedurami i funkcjami do obsługi tabeli REGIONS (CRUD), gdzie
--odczyt z różnymi parametrami
CREATE OR REPLACE PACKAGE regions_pkg AS

    PROCEDURE add_region (
        r_id REGIONS.region_id%TYPE,
        r_name REGIONS.region_name%TYPE
    );

    FUNCTION get_region (
        r_id REGIONS.region_id%TYPE
    ) RETURN REGIONS.region_name%TYPE;

    PROCEDURE rename_region (
        r_id REGIONS.region_id%TYPE,
        new_name REGIONS.region_name%TYPE
    );

    PROCEDURE remove_region (
        r_id REGIONS.region_id%TYPE
    );

END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg AS

    PROCEDURE add_region (
        r_id REGIONS.region_id%TYPE,
        r_name REGIONS.region_name%TYPE
    ) IS
    BEGIN
        INSERT INTO regions (region_id, region_name)
        VALUES (r_id, r_name);
        DBMS_OUTPUT.PUT_LINE('Dodano region: ' || r_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Błąd dodania regionu: ' || SQLERRM);
    END;

    FUNCTION get_region (
        r_id REGIONS.region_id%TYPE
    ) RETURN REGIONS.region_name%TYPE IS
        v_name REGIONS.region_name%TYPE;
    BEGIN
        SELECT region_name INTO v_name
        FROM regions
        WHERE region_id = r_id;
        RETURN v_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Region nie istnieje: ' || r_id);
    END;

    PROCEDURE rename_region (
        r_id REGIONS.region_id%TYPE,
        new_name REGIONS.region_name%TYPE
    ) IS
        changed_rows NUMBER;
    BEGIN
        UPDATE regions
        SET region_name = new_name
        WHERE region_id = r_id;

        changed_rows := SQL%ROWCOUNT;
        IF changed_rows = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Zmieniono nazwę regionu na: ' || new_name);
        END IF;
    END;

    PROCEDURE remove_region (
        r_id REGIONS.region_id%TYPE
    ) IS
        deleted_rows NUMBER;
    BEGIN
        DELETE FROM regions
        WHERE region_id = r_id;

        deleted_rows := SQL%ROWCOUNT;
        IF deleted_rows = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu do usunięcia.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Region usunięty.');
        END IF;
    END;

END regions_pkg;
/

-- TESTY ZADANIA 2

-- dodanie regionu
EXEC regions_pkg.add_region(999, 'Testlandia');

-- odczyt regionu
SELECT regions_pkg.get_region(999) AS region_name FROM dual;

-- aktualizacja nazwy
EXEC regions_pkg.rename_region(999, 'Nowa Testlandia');

-- usunięcie regionu
EXEC regions_pkg.remove_region(999);
