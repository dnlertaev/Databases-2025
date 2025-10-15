-- 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK ( age BETWEEN 18 AND 65),
    salary NUMERIC CHECK ( salary > 0 )
);

-- 1.2
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC CHECK (regular_price > 0),
    discount_price NUMERIC CHECK (discount_price > 0 AND discount_price < regular_price)

);

-- 1.3
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- 1.4
INSERT INTO employees VALUES (1, 'John', 'Snow', 20, 700);
INSERT INTO employees VALUES (2, 'Arya', 'Stark', 19, 800);
INSERT INTO employees VALUES (3, 'Sansa', 'Stark', 17, 1000); -- age < 18
INSERT INTO employees VALUES (4, 'Bran', 'Stark', 19, -2); -- salary < 0

INSERT INTO products_catalog VALUES (1, 'Valyrian Sword', 1000, 850);
INSERT INTO products_catalog VALUES (2, 'Dragon Egg', 5000, 4500);
INSERT INTO products_catalog VALUES (3, 'Crown of the North', 1200, 1200); -- discount = regular
INSERT INTO products_catalog VALUES (4, 'Potion of Resurrection', -50, 10); -- regular price < 0

INSERT INTO bookings VALUES (101, DATE '2025-10-20', DATE '2025-10-22', 4);
INSERT INTO bookings VALUES (102, DATE '2025-11-01', DATE '2025-11-05', 8);
INSERT INTO bookings VALUES (103, DATE '2025-10-10', DATE '2025-10-15', 15); -- num guests > 10
INSERT INTO bookings VALUES (104, DATE '2025-10-22', DATE '2025-10-20', 2); -- heck_out_date < check_in_date

-- 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- 2.2
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_update TIMESTAMP NOT NULL
);

-- 2.3
-- Successful insert
INSERT INTO customers VALUES (1, 'tywin@lannister.gold', '777-KL', DATE '2025-10-15');
-- Attempt with NULL in NOT NULL column
INSERT INTO customers VALUES (2, NULL, '555-WF', DATE '2025-10-16');  -- email NULL (ошибка)
-- Insert with NULL in nullable column
INSERT INTO customers VALUES (3, 'arya@stark.org', NULL, DATE '2025-10-17');

INSERT INTO inventory VALUES (201, 'Dragonbone Bow', 7, 900, NOW());
INSERT INTO inventory VALUES (202, 'Raven Quill', 20, 15, NULL);

-- 3.1
CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);
-- 3.2
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id    INTEGER,
    course_code   TEXT,
    semester      TEXT,
     CONSTRAINT uq_student_course_sem UNIQUE (student_id, course_code, semester)
);

-- 3.3
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username),
    ADD CONSTRAINT unique_email UNIQUE (email);

-- 4.1
CREATE TABLE departments (
  dept_id   INTEGER PRIMARY KEY,
  dept_name TEXT    NOT NULL,
  location  TEXT
);

INSERT INTO departments VALUES
  (10, 'Night''s Watch', 'The Wall'),
  (20, 'Small Council',  'King''s Landing'),
  (30, 'Maesters'' Guild', 'Oldtown');

-- 4.2
CREATE TABLE student_courses (
  student_id      INTEGER,
  course_id       INTEGER,
  enrollment_date DATE,
  grade           TEXT,
  PRIMARY KEY (student_id, course_id)
);

-- 4.3
-- Comparison
-- UNIQUE vs PRIMARY KEY:
-- PK = UNIQUE + NOT NULL, identifies each row; table can have only one.
-- UNIQUE just forbids duplicates; can allow NULLs and multiple per table.
-- Single PK if one column is enough; composite PK if two+ columns form identity.
-- Only one PK but many UNIQUE constraints possible.

-- 5.1
CREATE TABLE employees_dept (
  emp_id    INTEGER PRIMARY KEY,
  emp_name  TEXT    NOT NULL,
  dept_id   INTEGER REFERENCES departments(dept_id),
  hire_date DATE
);

INSERT INTO employees_dept VALUES
  (1, 'Jon Snow', 10, DATE '2025-10-10'),
  (2, 'Tyrion Lannister', 20, DATE '2025-10-11');

INSERT INTO employees_dept VALUES (3, 'Grey Worm', 999, DATE '2025-10-12');

-- 5.2
CREATE TABLE authors (
  author_id   INTEGER PRIMARY KEY,
  author_name TEXT    NOT NULL,
  country     TEXT
);

CREATE TABLE publishers (
  publisher_id   INTEGER PRIMARY KEY,
  publisher_name TEXT    NOT NULL,
  city           TEXT
);

CREATE TABLE books (
  book_id         INTEGER PRIMARY KEY,
  title           TEXT    NOT NULL,
  author_id       INTEGER REFERENCES authors(author_id),
  publisher_id    INTEGER REFERENCES publishers(publisher_id),
  publication_year INTEGER,
  isbn            TEXT UNIQUE
);

INSERT INTO authors VALUES
  (1, 'Archmaester Ebrose', 'Westeros'),
  (2, 'Septon Barth',       'Westeros');

INSERT INTO publishers VALUES
  (1, 'Citadel Press', 'Oldtown'),
  (2, 'Red Keep Print', 'King''s Landing');

INSERT INTO books VALUES
  (101, 'Dragons and Their Lore', 2, 2, 301, 'ISBN-RED-0001'),
  (102, 'Healing Arts of the Citadel', 1, 1, 299, 'ISBN-CIT-0002');

INSERT INTO books VALUES
  (103, 'Another Book', 1, 1, 300, 'ISBN-RED-0001');

-- 5.3
CREATE TABLE categories (
  category_id   INTEGER PRIMARY KEY,
  category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
  product_id   INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL,
  category_id  INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
  order_id   INTEGER PRIMARY KEY,
  order_date DATE NOT NULL
);

CREATE TABLE order_items (
  item_id   INTEGER PRIMARY KEY,
  order_id  INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products_fk(product_id),
  quantity   INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Steel'), (2, 'Food');
INSERT INTO products_fk VALUES (100, 'Valyrian Dagger', 1);
INSERT INTO orders VALUES (500, DATE '2025-10-15');
INSERT INTO order_items VALUES (900, 500, 100, 2);

DELETE FROM categories WHERE category_id = 1;
DELETE FROM orders WHERE order_id = 500;
SELECT * FROM order_items WHERE order_id = 500;

DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 6.1
CREATE TABLE customers (
  customer_id       INTEGER PRIMARY KEY,
  name              TEXT    NOT NULL,
  email             TEXT    NOT NULL UNIQUE,
  phone             TEXT,
  registration_date DATE    NOT NULL
);

CREATE TABLE products (
  product_id     INTEGER PRIMARY KEY,
  name           TEXT    NOT NULL,
  description    TEXT,
  price          NUMERIC NOT NULL CHECK (price >= 0),
  stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
  order_id     INTEGER PRIMARY KEY,
  customer_id  INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
  order_date   DATE    NOT NULL,
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
  status       TEXT    NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
  order_detail_id INTEGER PRIMARY KEY,
  order_id        INTEGER NOT NULL REFERENCES orders(order_id)   ON DELETE CASCADE,
  product_id      INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
  quantity        INTEGER NOT NULL CHECK (quantity > 0),
  unit_price      NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- 6.2
-- customers (5)
INSERT INTO customers VALUES
  (1, 'Jon Snow',     'jon@snow.wg',      '700-000', DATE '2025-10-01'),
  (2, 'Arya Stark',   'arya@wf.gov',      NULL,      DATE '2025-10-02'),
  (3, 'Sansa Stark',  'sansa@wf.gov',     '701-111', DATE '2025-10-03'),
  (4, 'Tyrion Lann.', 'tyrion@sc.gov',    '702-222', DATE '2025-10-04'),
  (5, 'Daenerys T.',  'dany@dragons.bay', '703-333', DATE '2025-10-05');

-- products (5)
INSERT INTO products VALUES
  (101, 'Valyrian Sword', 'Forged with magic',     1200, 5),
  (102, 'Dragonglass',    'White Walker remedy',    200, 50),
  (103, 'Raven Scroll',   'Official message',        15, 200),
  (104, 'Wildfire Jar',   'Handle with care',       500, 10),
  (105, 'Direwolf Cloak', 'Warm and stylish',       150, 25);

-- orders (5)
INSERT INTO orders VALUES
  (1001, 1, DATE '2025-10-10', 0,     'pending'),
  (1002, 2, DATE '2025-10-11', 0,     'processing'),
  (1003, 3, DATE '2025-10-12', 0,     'shipped'),
  (1004, 4, DATE '2025-10-13', 0,     'delivered'),
  (1005, 5, DATE '2025-10-14', 0,     'pending');

-- order_details (5+) — рассчитываем total_amount вручную (простая демонстрация)
INSERT INTO order_details VALUES
  (1, 1001, 101, 1, 1200),
  (2, 1001, 103, 2, 15),
  (3, 1002, 102, 3, 200),
  (4, 1003, 105, 2, 150),
  (5, 1004, 104, 1, 500);

UPDATE orders o
SET total_amount = sub.sum_amount
FROM (
  SELECT od.order_id, SUM(od.quantity * od.unit_price) AS sum_amount
  FROM order_details od
  GROUP BY od.order_id
) sub
WHERE o.order_id = sub.order_id;

-- 6.3
INSERT INTO customers VALUES
  (6, 'Fake', 'jon@snow.wg', NULL, DATE '2025-10-20');

INSERT INTO orders VALUES
  (2000, 1, DATE '2025-10-20', 0, 'on_the_way');

INSERT INTO products VALUES
  (200, 'Broken Item', 'Bad', -10, 1);

INSERT INTO order_details VALUES
  (6, 1005, 103, 0, 15);

DELETE FROM products WHERE product_id = 101;

DELETE FROM customers WHERE customer_id = 1;

DELETE FROM orders WHERE order_id = 1001;
SELECT * FROM order_details WHERE order_id = 1001;

UPDATE orders o
SET total_amount = sub.sum_amount
FROM (
  SELECT od.order_id, COALESCE(SUM(od.quantity * od.unit_price),0) AS sum_amount
  FROM order_details od
  GROUP BY od.order_id
) sub
WHERE o.order_id = sub.order_id;
