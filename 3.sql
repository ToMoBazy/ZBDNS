-- zad1
--Utwórz widok v_wysokie_pensje, dla tabeli employees który pokaże wszystkich
--pracowników zarabiających więcej niż 6000.
CREATE VIEW v_wysokie_pensje AS
SELECT * 
FROM employees
WHERE salary > 6000;

-- zad2
--Zmień definicję widoku v_wysokie_pensje aby pokazywał tylko pracowników
--zarabiających powyżej 12000. 
DROP VIEW v_wysokie_pensje;

CREATE VIEW v_wysokie_pensje AS
SELECT emp.*
FROM employees emp
WHERE emp.salary > 12000;


-- zad3
--Usuń widok v_wysokie_pensje. 
DROP VIEW v_wysokie_pensje;

-- zad4 
--Stwórz widok dla tabeli employees zawierający: employee_id, last_name, first_name, dla
--pracowników z departamentu o nazwie Finance
CREATE VIEW v_finance_pracownicy AS
SELECT 
    emp.employee_id,
    emp.last_name,
    emp.first_name
FROM 
    employees emp
    INNER JOIN departments dept ON emp.department_id = dept.department_id
WHERE 
    dept.department_name = 'Finance';
-- zad5
--Stwórz widok dla tabeli employees zawierający: employee_id, last_name, first_name,
--salary, job_id, email, hire_date dla pracowników mających zarobki pomiędzy 5000 a
--12000.

CREATE VIEW v_pracownicy_srednie_pensje AS
SELECT 
    emp.employee_id,
    emp.last_name,
    emp.first_name,
    emp.salary,
    emp.job_id,
    emp.email,
    emp.hire_date
FROM 
    employees emp
WHERE 
    emp.salary >= 5000 AND emp.salary <= 12000;

-- zad6
--Poprzez utworzone widoki sprawdź czy możesz:
-- a dodac pracownika
INSERT INTO v_pracownicy_srednie_pensje 
    (employee_id, first_name, last_name, salary, email, hire_date, job_id)
VALUES 
    (500, 'Tomasz', 'Piotrowski', 10000, 'tpiotrowski@wp.pl', 
     TO_DATE('14-05-2003', 'DD-MM-YYYY'), 'IT_PROG');

-- b edytowac pracownika
UPDATE v_pracownicy_srednie_pensje
SET last_name = 'Tomkowski'
WHERE employee_id = 500;

-- c usunac pracownika
DELETE FROM v_pracownicy_srednie_pensje WHERE employee_id = 500;

-- zad7
--Stwórz widok, który dla każdego działu który zatrudnia przynajmniej 4 pracowników
--wyświetli: identyfikator działu, nazwę działu, liczbę pracowników w dziale, średnią
--pensja w dziale i najwyższa pensja w dziale
CREATE VIEW v_statystyki AS
SELECT 
    dept.department_id,
    dept.department_name,
    COUNT(emp.employee_id) liczba_pracownikow,
    ROUND(AVG(emp.salary)) srednia_pensja,
    MAX(emp.salary) najwyzsza_pensja
FROM 
    departments dept
    JOIN employees emp ON dept.department_id = emp.department_id
GROUP BY 
    dept.department_id, dept.department_name
HAVING 
    COUNT(emp.employee_id) >= 4;

-- a
--nie mozna
-- zad8 
--Stwórz analogiczny widok zadania 3 z dodaniem warunku ‘WITH CHECK OPTION’.

CREATE OR REPLACE VIEW v_wysokie_pensje_5000_12000 AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id,
    e.email,
    e.hire_date,
    e.job_id,
    e.manager_id
FROM 
    employees e
WHERE 
    e.salary BETWEEN 5000 AND 12000
WITH CHECK OPTION;

-- a
-- I mozna dodac
INSERT INTO v_wysokie_pensje_5000_12000 
    (employee_id, first_name, last_name, salary, department_id, email, hire_date, job_id, manager_id)
VALUES 
    (500, 'Tomasz', 'Piotrowski', 7000, 50, 'tpiotrowski@wp.pl', 
     TO_DATE('14-05-2003', 'DD-MM-YYYY'), 'IT_PROG', 100);
-- II nie mozna SQL Error: ORA-01402: view WITH CHECK OPTION where-clause violation
INSERT INTO v_wysokie_pensje_5000_12000 
    (employee_id, first_name, last_name, salary, department_id, email, hire_date, job_id, manager_id)
VALUES 
    (501, 'Tomasz', 'Piotrowski', 17000, 50, 'tpiotrowski@wp.pl', 
     TO_DATE('14-05-2003', 'DD-MM-YYYY'), 'IT_PROG', 101);

-- zad9
-- Utwórz widok zmaterializowany v_managerowie, który pokaże tylko menedżerów w raz
--z nazwami ich działów
CREATE MATERIALIZED VIEW v_managerowie
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    dept.department_name
FROM 
    employees emp
    JOIN departments dept ON emp.employee_id = dept.manager_id;

-- zad10
--Stwórz widok v_najlepiej_oplacani, który zawiera tylko 10 najlepiej opłacanych
--pracowników
CREATE OR REPLACE VIEW v_najlepiej_oplacani AS
SELECT 
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    emp.salary,
    emp.job_id,
    emp.department_id
FROM 
    employees emp
ORDER BY emp.salary DESC
FETCH FIRST 10 ROWS ONLY;