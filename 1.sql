--zad 1
--Przygotuj bazę danych na podstawie niniejszego schematu.
--● Zwróć uwagę na klucze obce.
--● Sam dostosuj odpowiednie typy danych do kolumn.
--● Część kolumn oraz kluczy obcych dodaj za pomocą polecenia ALTER TABLE.
--● W tabeli JOBS ustaw warunek (CHECK), taki aby min_salary było mniejsze od
--max_salary co najmniej o 2000.


CREATE TABLE DEPARTMENTS (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL,
    manager_id NUMBER, 
    location_id NUMBER
);

CREATE TABLE JOBS (
    job_id NUMBER PRIMARY KEY,
    job_title VARCHAR(255) NOT NULL,
    min_salary DECIMAL(10, 2),
    max_salary DECIMAL(10, 2)
);

CREATE TABLE REGIONS (
    region_id  NUMBER PRIMARY KEY,
    region_name VARCHAR(255)
);

CREATE TABLE COUNTRIES (
    country_id  NUMBER PRIMARY KEY,
    country_name VARCHAR(255),
    region_id NUMBER
);

CREATE TABLE LOCATIONS (
    location_id NUMBER PRIMARY KEY,
    street_address VARCHAR(255),
    postal_code VARCHAR(25),
    city VARCHAR(255),
    state_province VARCHAR(100),
    country_id NUMBER
);

CREATE TABLE JOB_HISTORY (
    employee_id NUMBER,
    start_date DATE,
    end_date DATE,
    job_id NUMBER, 
    department_id NUMBER,
    PRIMARY KEY (employee_id, start_date)
);

CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),  
    email VARCHAR(100),  
    phone_number VARCHAR(20),
    hire_date DATE,
    salary NUMBER,
    commission_pct NUMBER(5, 2),
    job_id NUMBER,  
    manager_id NUMBER,
    department_id NUMBER
);



ALTER TABLE COUNTRIES 
ADD CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES REGIONS(region_id);

ALTER TABLE LOCATIONS 
ADD CONSTRAINT fk_locations_country FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id);

ALTER TABLE DEPARTMENTS 
ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id)
ON DELETE SET NULL;

ALTER TABLE DEPARTMENTS 
ADD CONSTRAINT fk_departments_location FOREIGN KEY (location_id) REFERENCES LOCATIONS(location_id);

ALTER TABLE EMPLOYEES 
ADD CONSTRAINT fk_employees_job FOREIGN KEY (job_id) REFERENCES JOBS(job_id);

ALTER TABLE EMPLOYEES 
ADD CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id)
ON DELETE SET NULL; 

ALTER TABLE EMPLOYEES 
ADD CONSTRAINT fk_employees_department FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id);

ALTER TABLE JOB_HISTORY 
ADD CONSTRAINT fk_job_history_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id)
ON DELETE CASCADE; 

ALTER TABLE JOB_HISTORY 
ADD CONSTRAINT fk_job_history_job FOREIGN KEY (job_id) REFERENCES JOBS(job_id);

ALTER TABLE JOB_HISTORY 
ADD CONSTRAINT fk_job_history_department FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id);

-- zad2
--Do tabeli JOBS wstaw 4 rekordy.
INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (1, 'programista', 4000, 26000);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (2, 'sprzedawca', 4000, 6000);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (3, 'pracownik_budowlany', 5000, 12000);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (4, 'ksiegowa', 5000, 8500);

-- zad3
--Wstaw 4 rekordy do tabeli EMPLOYEES
INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (1, 'Tomasz', 'Piotrowski', 'tpiotrowski@wp.pl', '517-760-226', TO_DATE('2024-03-06', 'YYYY-MM-DD'), 1, 6500, NULL, NULL, NULL);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (2, 'Adam', 'Rozwadowski', 'arozwadowski@wp.pl', '555-123-564', TO_DATE('2024-03-01', 'YYYY-MM-DD'), 1, 6500, NULL, NULL, NULL);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (3, 'Norbert', 'Rutkowski', 'nrutkowski@wp.pl', '558-567-222', TO_DATE('2023-06-03', 'YYYY-MM-DD'), 2, 4500, NULL, NULL, NULL);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (4, 'Patryk', 'Szczepański', 'pszczepanski@wp.pl', '556-128-354', TO_DATE('2022-03-15', 'YYYY-MM-DD'), 3, 10000, 0.10, NULL, NULL);

-- zad4 
--W tabeli EMPLOYEES zmień menadżera pracownikom o id 2 i 3 na 1
UPDATE EMPLOYEES SET manager_id = 1 WHERE employee_id IN (2, 3);

-- zad5
--Dla tabeli JOBS zwiększ minimalne i maksymalne wynagrodzenie o 500 jeśli nazwa zawiera
--‘b’ lub ‘s’

UPDATE JOBS SET  min_salary = min_salary + 500, max_salary = max_salary + 500 WHERE  LOWER(job_title) LIKE '%b%' OR LOWER(job_title) LIKE '%s%';

-- zad6
--Z tabeli JOBS usuń rekordy, dla których maksymalne zarobki są większe od 9000.
DELETE FROM EMPLOYEES WHERE job_id IN (SELECT job_id FROM JOBS WHERE max_salary > 9000);
DELETE FROM JOBS WHERE max_salary > 9000;

-- zad7
--Usuń jedną z tabel i sprawdź czy możesz ją odzyskać
DROP TABLE REGIONS CASCADE CONSTRAINTS;
FLASHBACK TABLE REGIONS TO BEFORE DROP;
