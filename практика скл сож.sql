-- 1. Пайдаланушылар жасау
CREATE USER u_admin WITH PASSWORD 'admin123';
CREATE USER u_acc WITH PASSWORD 'acc123';
CREATE USER u_mgr WITH PASSWORD 'mgr123';
CREATE USER u_aud WITH PASSWORD 'aud123';

-- 2. Рөлдер жасау
CREATE ROLE r_admin;
CREATE ROLE r_acc;
CREATE ROLE r_mgr;
CREATE ROLE r_aud;

-- 3. Рөлдерді пайдаланушыларға беру
GRANT r_admin TO u_admin;
GRANT r_acc TO u_acc;
GRANT r_mgr TO u_mgr;
GRANT r_aud TO u_aud;

CREATE SCHEMA bk;

CREATE TABLE bk.clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(50) UNIQUE
);
DROP TABLE IF EXISTS bk.income CASCADE;
CREATE TABLE bk.income (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES bk.clients(id),
    amt NUMERIC(10,2) NOT NULL CHECK (amt > 0),
    inc_date DATE NOT NULL,
    note TEXT
);
CREATE TABLE bk.expenses (
    id SERIAL PRIMARY KEY,
    amt NUMERIC(10,2) NOT NULL CHECK (amt > 0),
    exp_date DATE NOT NULL,
    cat VARCHAR(50)
);
CREATE TABLE bk.taxes (
    id SERIAL PRIMARY KEY,
    exp_id INT REFERENCES bk.expenses(id),
    type VARCHAR(50),
    amt NUMERIC(10,2) NOT NULL CHECK (amt >= 0),
    tax_date DATE NOT NULL
);
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA bk TO r_admin;
GRANT SELECT, INSERT, UPDATE ON bk.income, bk.expenses, bk.taxes TO r_acc;
GRANT SELECT ON bk.income, bk.expenses TO r_mgr;
GRANT SELECT ON ALL TABLES IN SCHEMA bk TO r_aud;

CREATE INDEX idx_clients_name ON bk.clients(name);
CREATE INDEX idx_income_client ON bk.income(client_id);
CREATE INDEX idx_exp_date ON bk.expenses(exp_date);

-- Мысалы, клиент қосу
INSERT INTO bk.clients(name, phone, email) VALUES ('Ali Nuray', '87001234567', 'ali@example.com');
-- Кіріс қосу
INSERT INTO bk.income(client_id, amt, inc_date, note) VALUES (1, 5000, '2026-02-27', 'Тест кіріс');
-- Шығыс қосу
INSERT INTO bk.expenses(amt, exp_date, cat) VALUES (2000, '2026-02-27', 'Жабдық');
-- Салық қосу
INSERT INTO bk.taxes(exp_id, type, amt, tax_date) VALUES (1, 'ҚҚС', 360, '2026-02-27');

SELECT 
    c.name, 
    i.amt AS income, 
    e.amt AS expense, 
    t.amt AS tax
FROM bk.clients c
LEFT JOIN bk.income i ON c.id = i.client_id
LEFT JOIN bk.expenses e ON TRUE          -- барлық expenses көрсетіледі
LEFT JOIN bk.taxes t ON e.id = t.exp_id; -- салықтарды expenses-ке байланыстыру
