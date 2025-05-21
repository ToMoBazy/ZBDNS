-- zad I
--Usuń wszystkie tabele ze swojej bazy
DROP TABLE COUNTRIES CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE JOBS CASCADE CONSTRAINTS;
DROP TABLE LOCATIONS CASCADE CONSTRAINTS;
DROP TABLE REGIONS CASCADE CONSTRAINTS;
DROP TABLE JOB_HISTORY CASCADE CONSTRAINTS;

-- zad II
--Przekopiuj wszystkie tabele wraz z danymi od użytkownika HR.
--Poustawiaj klucze główne i obce

CREATE TABLE EMPLOYEES AS SELECT * FROM HR.EMPLOYEES;
CREATE TABLE COUNTRIES AS SELECT * FROM HR.COUNTRIES;
CREATE TABLE DEPARTMENTS AS SELECT * FROM HR.DEPARTMENTS;
CREATE TABLE JOB_GRADES AS SELECT * FROM HR.JOB_GRADES;
CREATE TABLE JOB_HISTORY AS SELECT * FROM HR.JOB_HISTORY;
CREATE TABLE JOBS AS SELECT * FROM HR.JOBS;
CREATE TABLE LOCATIONS AS SELECT * FROM HR.LOCATIONS;
CREATE TABLE PRODUCTS AS SELECT * FROM HR.PRODUCTS;
CREATE TABLE REGIONS AS SELECT * FROM HR.REGIONS;
CREATE TABLE SALES AS SELECT * FROM HR.SALES;


 
ALTER TABLE SALES ADD CONSTRAINT PK_Sale_ID PRIMARY KEY (SALE_ID);
 
ALTER TABLE REGIONS ADD CONSTRAINT PK_Region_ID PRIMARY KEY (REGION_ID);
 
ALTER TABLE PRODUCTS ADD CONSTRAINT PK_Product_ID PRIMARY KEY (PRODUCT_ID);
 
ALTER TABLE LOCATIONS ADD CONSTRAINT PK_Location_ID PRIMARY KEY (LOCATION_ID);
 
ALTER TABLE JOBS ADD CONSTRAINT PK_Job_ID PRIMARY KEY (JOB_ID);
 
ALTER TABLE JOB_HISTORY ADD CONSTRAINT PK_EMPLOYEE_ID_START_DATE PRIMARY KEY (EMPLOYEE_ID,START_DATE);
 
ALTER TABLE JOB_GRADES ADD CONSTRAINT PK_Grade PRIMARY KEY (GRADE);
 
ALTER TABLE EMPLOYEES ADD CONSTRAINT PK_Employee_ID PRIMARY KEY (EMPLOYEE_ID);
 
ALTER TABLE DEPARTMENTS ADD CONSTRAINT PK_Department_ID PRIMARY KEY (DEPARTMENT_ID);
 
ALTER TABLE COUNTRIES  ADD CONSTRAINT PK_Country_ID PRIMARY KEY (COUNTRY_ID);
 
ALTER TABLE SALES ADD CONSTRAINT FK_EMPLOYEE_ID FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEES(EMPLOYEE_ID);
 
ALTER TABLE LOCATIONS ADD CONSTRAINT FK_Country_ID FOREIGN KEY (COUNTRY_ID) REFERENCES COUNTRIES(COUNTRY_ID);
 
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_DATE_INTERVAL CHECK (END_DATE > START_DATE);
 
ALTER TABLE JOB_HISTORY ADD CONSTRAINT FK_JH_DEP_ID FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID);
 
ALTER TABLE JOB_HISTORY ADD CONSTRAINT FK_JH_EMP_ID FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEES(employee_id);
 
ALTER TABLE JOB_HISTORY ADD CONSTRAINT FK_JH_JOB_ID FOREIGN KEY (JOB_ID) REFERENCES JOBS(JOB_ID);
 
ALTER TABLE EMPLOYEES ADD CONSTRAINT FK_EMP_DEP_ID FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID);
 
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_EMAIL_UK UNIQUE (EMAIL);
 
ALTER TABLE EMPLOYEES ADD CONSTRAINT FK_EMP_JOB_ID FOREIGN KEY (JOB_ID) REFERENCES JOBS(JOB_ID);
 
ALTER TABLE EMPLOYEES ADD CONSTRAINT FK_EMP_MANAGER_ID FOREIGN KEY (MANAGER_ID) REFERENCES EMPLOYEES(EMPLOYEE_ID);
 
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_SALLARY_MIN CHECK (SALARY > 0);
 
ALTER TABLE DEPARTMENTS ADD CONSTRAINT FK_DEP_LOC_ID FOREIGN KEY (LOCATION_ID) REFERENCES LOCATIONS(LOCATION_ID);
 
ALTER TABLE DEPARTMENTS  ADD CONSTRAINT FK_DEP_MANAGER_ID FOREIGN KEY (MANAGER_ID) REFERENCES EMPLOYEES(EMPLOYEE_ID);
 
ALTER TABLE COUNTRIES ADD CONSTRAINT FK_COUNTR_REG_ID FOREIGN KEY (REGION_ID) REFERENCES REGIONS(REGION_ID);

-- zad III
--Stwórz następujące perspektywy lub zapytania, dodaj wszystko do
--swojego repozytorium:


-- zad1
--1. Z tabeli employees wypisz w jednej kolumnie nazwisko i zarobki – nazwij
--kolumnę wynagrodzenie, dla osób z departamentów 20 i 50 z zarobkami
--pomiędzy 2000 a 7000, uporządkuj kolumny według nazwiska 
SELECT CONCAT(last_name, ' - ' || salary) AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

-- zad2
--Z tabeli employees wyciągnąć informację data zatrudnienia, nazwisko oraz
--kolumnę podaną przez użytkownika dla osób mających menadżera
--zatrudnionych w roku 2005. Uporządkować według kolumny podanej przez
--użytkownika
--DEFINE kolumna = 'salary';

SELECT hire_date, last_name, &kolumna AS wybrana_kolumna
FROM employees
WHERE manager_id IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY &kolumna;

-- zad3
--Wypisać imiona i nazwiska razem, zarobki oraz numer telefonu porządkując
--dane według pierwszej kolumny malejąco a następnie drugiej rosnąco (użyć
--numerów do porządkowania) dla osób z trzecią literą nazwiska ‘e’ oraz częścią
--imienia podaną przez użytkownika

DEFINE imie_czesc = 'el';

SELECT first_name || ' ' || last_name AS imie_nazwisko,
       salary,
       phone_number
FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'e'
  AND INSTR(LOWER(first_name), LOWER('&imie_czesc')) > 0
ORDER BY imie_nazwisko DESC, salary ASC;

-- zad4
--Wypisać imię i nazwisko, liczbę miesięcy przepracowanych – funkcje
--months_between oraz round oraz kolumnę wysokość_dodatku jako (użyć CASE
--lub DECODE):
--● 10% wynagrodzenia dla liczby miesięcy do 150
--● 20% wynagrodzenia dla liczby miesięcy od 150 do 200
--● 30% wynagrodzenia dla liczby miesięcy od 200
--● uporządkować według liczby miesięcy
SELECT first_name || ' ' || last_name AS imie_nazwisko,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS miesiace_pracy,
       CASE
         WHEN MONTHS_BETWEEN(SYSDATE, hire_date) < 150 THEN salary * 0.10
         WHEN MONTHS_BETWEEN(SYSDATE, hire_date) BETWEEN 150 AND 199 THEN salary * 0.20
         ELSE salary * 0.30
       END AS dodatek
FROM employees
ORDER BY miesiace_pracy;

-- zad5
--Dla każdego działów w których minimalna płaca jest wyższa niż 5000 wypisz
--sumę oraz średnią zarobków zaokrągloną do całości nazwij odpowiednio
--kolumny

SELECT department_id,
       SUM(salary) AS suma_zarobkow,
       TRUNC(AVG(salary)) AS srednia_zarobkow
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;

-- zad6
--Wypisać nazwisko, numer departamentu, nazwę departamentu, id pracy, dla
--osób z pracujących Toronto
SELECT e.last_name,
       e.department_id,
       d.department_name,
       e.job_id
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN locations l ON l.location_id = d.location_id
WHERE LOWER(l.city) = 'toronto';


-- zad7
--Dla pracowników o imieniu „Jennifer” wypisz imię i nazwisko tego pracownika
--oraz osoby które z nim współpracują
SELECT j.first_name || ' ' || j.last_name AS jennifer,
       e.first_name || ' ' || e.last_name AS wspolpracownik
FROM employees j
JOIN employees e ON e.department_id = j.department_id AND e.employee_id != j.employee_id
WHERE j.first_name = 'Jennifer';
-- zad8
--Wypisać wszystkie departamenty w których nie ma pracowników
SELECT d.department_id,
       d.department_name
FROM departments d
LEFT OUTER JOIN employees e ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;

-- zad9
--Wypisz imię i nazwisko, id pracy, nazwę departamentu, zarobki, oraz
--odpowiedni grade dla każdego pracownika
SELECT e.first_name || ' ' || e.last_name AS imie_nazwisko,
       e.job_id,
       d.department_name,
       e.salary,
       g.grade AS grade_level
FROM employees e
JOIN departments d USING (department_id)
JOIN job_grades g ON e.salary BETWEEN g.min_salary AND g.max_salary;
-- zad10
--Wypisz imię nazwisko oraz zarobki dla osób które zarabiają więcej niż średnia
--wszystkich, uporządkuj malejąco według zarobków

SELECT first_name || ' ' || last_name AS imie_nazwisko,
       salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- zad11
--Wypisz id imię i nazwisko osób, które pracują w departamencie z osobami
--mającymi w nazwisku „u”

SELECT employee_id,
       first_name,
       last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE LOWER(last_name) LIKE '%u%'
      AND department_id IS NOT NULL
);

-- zad12
--Znajdź pracowników, którzy pracują dłużej niż średnia długość zatrudnienia w
--firmie.
SELECT employee_id,
       first_name,
       last_name,
       hire_date,
       TRUNC(SYSDATE - hire_date) AS dni_zatrudnienia
FROM employees
WHERE SYSDATE - hire_date > (
    SELECT AVG(SYSDATE - hire_date)
    FROM employees
)
ORDER BY dni_zatrudnienia DESC;
-- zad13
--Wypisz nazwę departamentu, liczbę pracowników oraz średnie wynagrodzenie
--w każdym departamencie. Sortuj według liczby pracowników malejąco.
SELECT d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       TRUNC(AVG(e.salary)) AS srednie_wynagrodzenie
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY liczba_pracownikow DESC;
-- zad14
--Wypisz imiona i nazwiska pracowników, którzy zarabiają mniej niż jakikolwiek
--pracownik w departamencie „IT”.
SELECT first_name,
       last_name,
       salary
FROM employees
WHERE salary < (
    SELECT MIN(e.salary)
    FROM employees e
    JOIN departments d ON d.department_id = e.department_id
    WHERE LOWER(d.department_name) = 'it'
);

-- zad15
--Znajdź departamenty, w których pracuje co najmniej jeden pracownik
--zarabiający więcej niż średnia pensja w całej firmie.

SELECT DISTINCT d.department_id,
       d.department_name
FROM departments d
JOIN employees e ON e.department_id = d.department_id
WHERE e.salary > (SELECT AVG(salary) FROM employees);
-- zad16
--Wypisz pięć najlepiej opłacanych stanowisk pracy wraz ze średnimi zarobkami.
SELECT j.job_title,
       ROUND(AVG(e.salary)) AS srednie_zarobki
FROM jobs j
JOIN employees e ON j.job_id = e.job_id
GROUP BY j.job_title
ORDER BY srednie_zarobki DESC
FETCH FIRST 5 ROWS ONLY;

-- zad17
--Dla każdego regionu, wypisz nazwę regionu, liczbę krajów oraz liczbę
--pracowników, którzy tam pracują.
SELECT r.region_name,
       COUNT(DISTINCT c.country_id) AS liczba_krajow,
       COUNT(e.employee_id) AS liczba_pracownikow
FROM regions r
LEFT JOIN countries c ON c.region_id = r.region_id
LEFT JOIN locations l ON l.country_id = c.country_id
LEFT JOIN departments d ON d.location_id = l.location_id
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY r.region_name;
-- zad18
--Podaj imiona i nazwiska pracowników, którzy zarabiają więcej niż ich
--menedżerowie.
SELECT e.first_name || ' ' || e.last_name AS pracownik,
       e.salary AS pensja_pracownika,
       m.first_name || ' ' || m.last_name AS menedzer,
       m.salary AS pensja_menedzera
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- zad19
--Policz, ilu pracowników zaczęło pracę w każdym miesiącu (bez względu na rok).
SELECT TO_CHAR(hire_date, 'MM') AS miesiac_nr,
       INITCAP(TO_CHAR(hire_date, 'Month')) AS miesiac_nazwa,
       COUNT(*) AS liczba_pracownikow
FROM employees
GROUP BY TO_CHAR(hire_date, 'MM'), TO_CHAR(hire_date, 'Month')
ORDER BY miesiac_nr;

-- zad20
--Znajdź trzy departamenty z najwyższą średnią pensją i wypisz ich nazwę oraz
--średnie wynagrodzenie.
SELECT 
    d.department_name,
    ROUND(AVG(e.salary)) AS srednia_pensja
FROM 
    employees e
JOIN 
    departments d ON e.department_id = d.department_id
GROUP BY 
    d.department_name
ORDER BY 
    srednia_pensja DESC
FETCH FIRST 3 ROWS ONLY;



