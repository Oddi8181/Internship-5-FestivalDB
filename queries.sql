-- 1.
SELECT
    w.workshop_name,
    w.workshop_level,
    f.festival_name,
    f.official_start
FROM
    workshop w
JOIN
    festival f ON w.festival_id = f.id
WHERE
    w.workshop_level = 'napredna' AND
    EXTRACT(YEAR FROM f.official_start) = 2025;

-- 2. 
SELECT
    p.preformer_name AS izvodjac,
    f.festival_name AS festival,
    s.stage_name AS pozornica,
    perf.start_time AS vrijeme_pocetka
FROM
    preformance perf 
JOIN
    preformer p ON perf.preformer_id = p.id
JOIN
    festival f ON perf.festival_id = f.id
JOIN
    stage s ON perf.stage_id = s.id
WHERE
    perf.expected_number_of_visitors > 10000;

-- 3.
SELECT
    festival_name,
    official_start,
    official_end
FROM
    festival
WHERE
    EXTRACT(YEAR FROM official_start) = 2025 OR
    EXTRACT(YEAR FROM official_end) = 2025 OR
    (official_start < '2025-01-01' AND official_end > '2025-12-31');
    

-- 4.
SELECT
    workshop_name,
    workshop_level,
    duration_time
FROM
    workshop
WHERE
    workshop_level = 'napredna';

-- 5.
SELECT
    workshop_name,
    duration_time AS trajanje_sati
FROM
    workshop
WHERE
    duration_time > 4;

-- 6. 
SELECT
    workshop_name,
    needs_prior_knowledge AS zahtijeva_znanje
FROM
    workshop
WHERE
    needs_prior_knowledge = TRUE;

-- 7. 
SELECT
    mentor_name,
    mentor_surname,
    years_of_experience AS godine_iskustva
FROM
    mentor
WHERE
    years_of_experience > 10;

-- 8. 
SELECT
    mentor_name,
    mentor_surname,
    date_of_birth AS datum_rodenja
FROM
    mentor
WHERE
    EXTRACT(YEAR FROM date_of_birth) < 1985;
   

-- 9. 
SELECT
    visitor_name,
    visitor_surname,
    city AS grad
FROM
    visitor
WHERE
    city = 'Split';

-- 10.
SELECT
    visitor_name,
    visitor_surname,
    email
FROM
    visitor
WHERE
    email LIKE '%@gmail.com';

-- 11.
SELECT
    visitor_name,
    visitor_surname,
    date_of_birth
FROM
    visitor
WHERE
    AGE(date_of_birth) < INTERVAL '25 years';
 

-- 12.
SELECT
    ticket_type,
    price AS cijena_eura,
    ticket_description
FROM
    ticket
WHERE
    price > 120.00;

-- 13. 
SELECT
    ticket_type,
    price,
    festival_id
FROM
    ticket
WHERE
    ticket_type = 'VIP';

-- 14. 
SELECT
    ticket_type,
    is_valid_whole_festival AS vrijedi_cijeli_festival,
    validation_date
FROM
    ticket
WHERE
    ticket_type = 'festival' AND is_valid_whole_festival = TRUE;

-- 15. 
SELECT
    staff_name,
    staff_surname,
    staff_role AS uloga,
    safety_check AS sigurnosna_obuka
FROM
    staff
WHERE
    safety_check = TRUE;
