-- zad1
--Stwórz ranking pracowników oparty na wysokości pensji. Jeśli dwie osoby mają tę samą
--pensję, powinny otrzymać ten sam numer.
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    RANK() OVER (ORDER BY e.salary DESC) AS pozycja
FROM 
    employees e;


-- zad2
--Dodaj kolumnę, która pokazuje całkowitą sumę pensji wszystkich pracowników, ale bez
--grupowania ich.

SELECT 
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    emp.salary,
    SUM(emp.salary) OVER () AS laczna_pensja
FROM 
    employees emp;
-- zad3
--Dla każdego pracownika wypisz: nazwisko, nazwę produktu, skumulowaną wartość
--sprzedaży dla pracownika, ranking wartości sprzedaży względem wszystkich
--zamówień.
SELECT 
    emp.last_name AS pracownik,
    prod.product_name AS produkt,
    SUM(s.price * s.quantity) AS laczna_sprzedaz,
    RANK() OVER (ORDER BY SUM(s.price * s.quantity) DESC) AS ranking
FROM 
    sales s
JOIN employees emp ON s.employee_id = emp.employee_id
JOIN products prod ON s.product_id = prod.product_id
GROUP BY 
    emp.last_name, prod.product_name;
-- zad4 
--Dla każdego wiersza z tabeli sales wypisać nazwisko pracownika, nazwę produktu, cenę
--produktu, liczbę transakcji dla danego produktu tego dnia, sumę zapłaconą danego dnia
--za produkt, poprzednią cenę oraz kolejną cenę danego produktu.
SELECT 
    emp.last_name AS pracownik,
    prod.product_name AS produkt,
    s.price AS cena_sprzedazy,

    COUNT(*) OVER (PARTITION BY s.product_id, s.sale_date) AS liczba_transakcji,
    SUM(s.price * s.quantity) OVER (PARTITION BY s.product_id, s.sale_date) AS suma_dzienna,

    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS cena_wczesniejsza,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS cena_kolejna

FROM 
    sales s
JOIN employees emp ON s.employee_id = emp.employee_id
JOIN products prod ON s.product_id = prod.product_id;

-- zad5
--Dla każdego wiersza wypisać nazwę produktu, cenę produktu, sumę całkowitą
--zapłaconą w danym miesiącu oraz sumę rosnącą zapłaconą w danym miesiącu za
--konkretny produkt
SELECT 
    pr.product_name,
    s.price,
    TO_CHAR(s.sale_date, 'YYYY-MM') AS okres,

    SUM(s.price * s.quantity) OVER (
        PARTITION BY pr.product_id, TO_CHAR(s.sale_date, 'YYYY-MM')
    ) AS miesieczna_suma,

    SUM(s.price * s.quantity) OVER (
        PARTITION BY pr.product_id, TO_CHAR(s.sale_date, 'YYYY-MM')
        ORDER BY s.sale_date
    ) AS suma_narastajaca

FROM 
    sales s
JOIN products pr ON s.product_id = pr.product_id;


-- zad6
--Wypisać obok siebie cenę produktu z roku 2022 i roku 2023 z tego samego dnia oraz
--dodatkowo różnicę pomiędzy cenami tych produktów oraz dodatkowo nazwę produktu
--i jego kategorię

SELECT 
    pr.product_name,
    pr.product_category,
    TO_CHAR(s22.sale_date, 'MM-DD') AS dzien,
    s22.price AS cena_2022,
    s23.price AS cena_2023,
    s23.price - s22.price AS roznica

FROM 
    sales s22
JOIN sales s23 ON s22.product_id = s23.product_id
              AND TO_CHAR(s22.sale_date, 'MM-DD') = TO_CHAR(s23.sale_date, 'MM-DD')
              AND EXTRACT(YEAR FROM s22.sale_date) = 2022
              AND EXTRACT(YEAR FROM s23.sale_date) = 2023
JOIN products pr ON s22.product_id = pr.product_id;


-- zad7 
--Dla każdego wiersza wypisać nazwę kategorii produktu, nazwę produktu, jego cenę,
--minimalną cenę w danej kategorii, maksymalną cenę w danej kategorii, różnicę między
--maksymalną a minimalną ceną.
SELECT 
    pr.product_category,
    pr.product_name,
    s.price AS cena,

    MIN(s.price) OVER (PARTITION BY pr.product_category) AS min_w_kategorii,
    MAX(s.price) OVER (PARTITION BY pr.product_category) AS max_w_kategorii,
    MAX(s.price) OVER (PARTITION BY pr.product_category) -
    MIN(s.price) OVER (PARTITION BY pr.product_category) AS roznica

FROM 
    sales s
JOIN products pr ON s.product_id = pr.product_id;

-- zad8
--Dla każdego wiersza wypisz nazwę produktu i średnią kroczącą ceny (biorącą pod
--uwagę poprzednią, bieżącą i następną cenę) tego produktu według kolejnych dat
SELECT 
    p.product_name,
    s.sale_date,
    s.price AS cena,

    ROUND((
        NVL(LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date), 0) +
        s.price +
        NVL(LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date), 0)
    ) /
    CASE 
        WHEN LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) IS NOT NULL AND
             LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) IS NOT NULL THEN 3
        ELSE 2
    END, 2) AS srednia_kroczaca

FROM 
    sales s
JOIN products p ON s.product_id = p.product_id;


-- zad9
--Dla każdego wiersza nazwę produktu, kategorię oraz ranking cen wewnątrz kategorii,
--ponumerowane wiersze wewnątrz kategorii w zależności od ceny oraz ranking gęsty
--(dense) cen wewnątrz kategorii

SELECT 
    p.product_category,
    p.product_name,
    s.price AS cena,

    RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking,
    ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS numer,
    DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS gesty_ranking

FROM 
    sales s
JOIN products p ON s.product_id = p.product_id;


-- zad10
--Dla każdego wiersza tabeli sales nazwisko pracownika, nazwa produktu, wartość
--rosnąca jego sprzedaży według dat (cena produktu * ilość) dla danego pracownika oraz
--ranking wartości sprzedaży dla kolejnych wierszy globalnie według wartości
--zamówienia
SELECT 
    e.last_name AS nazwisko,
    p.product_name AS produkt,
    s.sale_date AS data,
    s.price * s.quantity AS wartosc,

    RANK() OVER (ORDER BY s.price * s.quantity DESC) AS pozycja

FROM 
    sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id

ORDER BY 
    e.last_name, s.sale_date;


-- zad11
--Nie używając funkcji okienkowych wyświetl: Imiona i nazwiska pracowników oraz ich
--stanowisko, którzy uczestniczyli w sprzedaży
SELECT 
    DISTINCT e.first_name,
             e.last_name,
             e.job_id
FROM 
    employees e
WHERE 
    EXISTS (
        SELECT 1 FROM sales s WHERE s.employee_id = e.employee_id
    );
