CREATE TABLE festival(
    id SERIAL PRIMARY KEY,
    festival_name VARCHAR(200) NOT NULL,
    city VARCHAR(200) NOT NULL,
    capacity INT NOT NULL,
    official_start DATE NOT NULL,
    official_end DATE NOT NULL,
    festival_status VARCHAR(50) CHECK (festival_status IN ('planiran','aktivan','zavrsen')), 
    camp BOOLEAN DEFAULT FALSE
);

CREATE TABLE stage(
    id SERIAL PRIMARY KEY,
    stage_name VARCHAR(150) NOT NULL,
    capacity INT NOT NULL,
    stage_location VARCHAR(200),
    covered BOOLEAN DEFAULT FALSE, 
    festival_id INT NOT NULL REFERENCES festival(id) ON DELETE CASCADE
);

CREATE TABLE preformer(
    id SERIAL PRIMARY KEY,
    preformer_name VARCHAR(200) NOT NULL,
    country VARCHAR(200),
    genre VARCHAR(200),
    member_no INT,
    active BOOLEAN 
);

CREATE TABLE preformance(
    id SERIAL PRIMARY KEY,  
    festival_id INT NOT NULL REFERENCES festival(id) ON DELETE CASCADE,
    stage_id INT NOT NULL REFERENCES stage(id) ON DELETE CASCADE,
    preformer_id INT NOT NULL REFERENCES preformer(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    expected_number_of_visitors INT,
    CHECK (end_time > start_time)
);

CREATE TABLE visitor(
    id SERIAL PRIMARY KEY,
    visitor_name VARCHAR(100) NOT NULL,
    visitor_surname VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    city VARCHAR(250),
    email VARCHAR(250) UNIQUE,
    country VARCHAR(200)
);

CREATE TABLE ticket(
    id SERIAL PRIMARY KEY,
    festival_id INT NOT NULL REFERENCES festival(id) ON DELETE CASCADE,
    ticket_type VARCHAR(200),
    price DECIMAL(10,2),
    ticket_description TEXT,
    validation_date DATE,
    is_valid_whole_festival BOOLEAN DEFAULT FALSE
);

CREATE TABLE purchase(
    id SERIAL PRIMARY KEY,
    visitor_id INT NOT NULL REFERENCES visitor(id) ON DELETE CASCADE,
    festival_id INT NOT NULL REFERENCES festival(id) ON DELETE CASCADE,
    purchase_date DATE NOT NULL,
    purchase_time TIME NOT NULL,
    total_price DECIMAL(12,2) DEFAULT 0
);

CREATE TABLE order_item(
    id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL REFERENCES purchase(id) ON DELETE CASCADE, 
    ticket_id INT NOT NULL REFERENCES ticket(id) ON DELETE CASCADE,   
    amount INT NOT NULL CHECK (amount > 0)  
);

CREATE TABLE mentor(
    id SERIAL PRIMARY KEY,
    mentor_name VARCHAR(100) NOT NULL,
    mentor_surname VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL, 
    expertise VARCHAR(255),
    years_of_experience INT NOT NULL
);

CREATE TABLE workshop (
    id SERIAL PRIMARY KEY,
    festival_id INT NOT NULL REFERENCES festival(id) ON DELETE CASCADE,
    mentor_id INT NOT NULL REFERENCES mentor(id) ON DELETE SET NULL,
    workshop_name VARCHAR(255) NOT NULL,
    workshop_level VARCHAR(20) CHECK (workshop_level IN ('pocetna','srednja','napredna')),
    max_atendee INT,
    duration_time INT,
    needs_prior_knowledge BOOLEAN DEFAULT FALSE
);

CREATE TABLE signin_workshop(
    id SERIAL PRIMARY KEY,
    workshop_id INT NOT NULL REFERENCES workshop(id) ON DELETE CASCADE,
    visitor_id INT NOT NULL REFERENCES visitor(id) ON DELETE CASCADE,
    workshop_status VARCHAR(200) CHECK(workshop_status IN ('prijavljen','otkazan','prisutan')), 
    signin_time TIMESTAMP DEFAULT NOW()
);

CREATE TABLE staff(
    id SERIAL PRIMARY KEY,
    festival_id INT REFERENCES festival(id),
    staff_name VARCHAR(100),
    staff_surname VARCHAR(100),
    date_of_birth DATE,
    staff_role VARCHAR(100),
    contact VARCHAR(255),
    safety_check BOOLEAN,
    CHECK (
        staff_role <> 'zastitar' 
        OR date_of_birth <= (CURRENT_DATE - INTERVAL '21 years')
    )
);

CREATE TABLE membership(
    id SERIAL PRIMARY KEY,
    visitor_id INT UNIQUE REFERENCES visitor(id),
    activation_date DATE,
    membership_status VARCHAR(50)
);
