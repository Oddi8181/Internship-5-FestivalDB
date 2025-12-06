

BEGIN;


INSERT INTO festival (festival_name, city, capacity, official_start, official_end, festival_status, camp)
SELECT
  'Festival_' || g,
  'City_' || (1 + ((g % 40))),
  (2000 + (random()*48000))::int,
  (date '2024-01-01' + ((floor(random()*1000))::int))::date,
  (date '2024-01-02' + ((floor(random()*1000))::int))::date,
  (ARRAY['planiran','aktivan','zavrsen'])[(floor(random()*3)+1)],
  (random() < 0.35)
FROM generate_series(1,80) g;


UPDATE festival
SET official_end = official_start + ( (1 + floor(random()*5)) :: int )
WHERE official_end < official_start;


INSERT INTO mentor (mentor_name, mentor_surname, date_of_birth, expertise, years_of_experience)
SELECT
  initcap(substr(md5(random()::text),1,6)),
  initcap(substr(md5(random()::text),7,6)),
  (date '1960-01-01' + ( (floor(random()*15000))::int ))::date,
  (ARRAY['DJing','Production','Sound','Songwriting','Marketing'])[(floor(random()*5)+1)],
  (2 + (floor(random()*28)) )
FROM generate_series(1,150);


INSERT INTO visitor (visitor_name, visitor_surname, date_of_birth, city, email, country)
SELECT
  initcap(substr(md5(random()::text),1,6)),
  initcap(substr(md5(random()::text),7,6)),
  (date '1960-01-01' + ((floor(random()*16000))::int))::date,
  'City_' || (1 + ((floor(random()*30))::int)),
  lower(substr(md5(random()::text),1,5)) || g || '@gmail.com',
  (ARRAY['Croatia','Slovenia','Italy','Germany','Austria'])[(floor(random()*5)+1)]
FROM generate_series(1,1200) g;


INSERT INTO preformer (preformer_name, country, genre, member_no, active)
SELECT
  'Artist_' || g,
  (ARRAY['Croatia','UK','USA','Germany','Sweden','France'])[(floor(random()*6)+1)],
  (ARRAY['rock','pop','techno','jazz','hiphop','metal'])[(floor(random()*6)+1)],
  (1 + (floor(random()*8)) )::int,
  (random() < 0.8)
FROM generate_series(1,1500) g;






INSERT INTO stage (stage_name, capacity, stage_location, covered, festival_id)
SELECT
  'Stage_' || g,
  (500 + (floor(random()*19500)))::int,
  (ARRAY['main','forest','beach','side'])[(floor(random()*4)+1)],
  (random() < 0.5),
  f.id 
FROM generate_series(1,300) g
JOIN festival f ON f.id = (SELECT id FROM festival ORDER BY random() LIMIT 1);



WITH fest_count AS (
  SELECT id FROM festival
),
tickets_per_fest AS (
  SELECT id as festival_id, (2 + (floor(random()*5))::int) as n FROM fest_count
),

ticket_data AS (
    SELECT
        tf.festival_id,
        (2 + (floor(random()*5))::int) as n,
        gs.g as ticket_index,
        random() as decision_rand 
    FROM tickets_per_fest tf, generate_series(1, tf.n) gs(g)
)
INSERT INTO ticket (festival_id, ticket_type, price, ticket_description, validation_date, is_valid_whole_festival)
SELECT
  td.festival_id,
  (ARRAY['day','festival','VIP','camp'])[(floor(random()*4)+1)],
  round((40 + random()*310)::numeric,2),
  'Includes_' || (ARRAY['backstage','camp','parking','none'])[(floor(random()*4)+1)],

 
  CASE WHEN td.decision_rand < 0.7 THEN NULL
       ELSE (
            SELECT official_start FROM festival f WHERE f.id=td.festival_id
       ) + (floor(random()*5)::int) 
  END as validation_date,

  (td.decision_rand < 0.7)
FROM ticket_data td;


INSERT INTO preformance (festival_id, stage_id, preformer_id, start_time, end_time, expected_number_of_visitors)
SELECT
  f.id,
  s.id,
  (1 + floor(random()*1500))::int,
  ( (f.official_start + (floor(random()*((f.official_end - f.official_start)+1))::int) )::timestamp + ( (12 + floor(random()*12)) || ' hours')::interval ),
  ( (f.official_start + (floor(random()*((f.official_end - f.official_start)+1))::int) )::timestamp + ( (12 + floor(random()*12)) || ' hours')::interval + ( (30 + 30*floor(random()*5)) || ' minutes')::interval ),
  (50 + floor(random()*GREATEST(f.capacity,20000)))::int
FROM (
  SELECT id, official_start, official_end, capacity FROM festival
) f
JOIN LATERAL (
  SELECT id FROM stage WHERE festival_id = f.id ORDER BY random() LIMIT 1
) s ON true

JOIN generate_series(1,3500) gs(x) ON true
LIMIT 3500;


INSERT INTO workshop (festival_id, mentor_id, workshop_name, workshop_level, max_atendee, duration_time, needs_prior_knowledge)
SELECT
  (1 + floor(random()*80))::int,
  (1 + floor(random()*150))::int,
  'Workshop_' || g,
  (ARRAY['pocetna','srednja','napredna'])[(floor(random()*3)+1)],
  (10 + floor(random()*190))::int,
  (1 + floor(random()*8))::int,
  (random() < 0.4)
FROM generate_series(1,300) g;


INSERT INTO signin_workshop (workshop_id, visitor_id, workshop_status, signin_time)
SELECT
  (1 + floor(random()*300))::int,    
  (1 + floor(random()*1200))::int,
  (ARRAY['prijavljen','otkazan','prisutan'])[(floor(random()*3)+1)],
  (now() - (floor(random()*2000))::int * '1 day'::interval)
FROM generate_series(1,500) g;


INSERT INTO staff (festival_id, staff_name, staff_surname, date_of_birth, staff_role, contact, safety_check)
SELECT
  (1 + floor(random()*80))::int,
  initcap(substr(md5(random()::text),1,6)),
  initcap(substr(md5(random()::text),7,6)),
  (date '1950-01-01' + ((floor(random()*20000))::int))::date,
  (ARRAY['zastitar','tehnicar','organizator','volonter'])[(floor(random()*4)+1)],
  ('+' || (300000000 + floor(random()*700000000))::text),
  (random() < 0.6)
FROM generate_series(1,800) g;


INSERT INTO purchase (visitor_id, festival_id, purchase_date, purchase_time, total_price)
SELECT
  (1 + floor(random()*1200))::int,
  (1 + floor(random()*80))::int,
  (date '2024-01-01' + (floor(random()*1000))::int),
  ( (floor(random()*86400))::int * '1 second'::interval )::time,
  0.00
FROM generate_series(1,2000) g;


INSERT INTO order_item (purchase_id, ticket_id, amount)
SELECT
  p.id,
  t.id,
  1 + floor(random()*4)::int
FROM (
  SELECT id, festival_id FROM purchase ORDER BY random() LIMIT 3500
) p
JOIN LATERAL (
  SELECT id FROM ticket WHERE festival_id = p.festival_id ORDER BY random() LIMIT 1
) t ON true
LIMIT 3500;


UPDATE purchase pu
SET total_price = coalesce(sub.total, 0)
FROM (
  SELECT oi.purchase_id AS pid, sum(oi.amount * t.price) AS total
  FROM order_item oi
  JOIN ticket t ON t.id = oi.ticket_id
  GROUP BY oi.purchase_id
) sub
WHERE pu.id = sub.pid;


INSERT INTO membership (visitor_id, activation_date, membership_status)
SELECT DISTINCT ON (v)
  v,
  (date '2024-01-01' + (floor(random()*1000))::int),
  (ARRAY['aktivan','istekao'])[(floor(random()*2)+1)]
FROM (
  SELECT (1 + floor(random()*1200))::int as v
  FROM generate_series(1,400)
) s
LIMIT 300;

COMMIT;
