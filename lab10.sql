-- 3.1
CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);


-- 3.2
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
UPDATE accounts SET balance = balance + 100 WHERE name='Bob';
COMMIT;

-- 3.3
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE name='Alice';
SELECT * FROM accounts WHERE name='Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name='Alice';

-- 3.4
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100 WHERE name='Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100 WHERE name='Wally';
COMMIT;

-- 3.6
SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';

-- 3.7
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

BEGIN;
UPDATE products SET price = 99.99
 WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;

-- 4.1
BEGIN;

-- Блокируем строку Bob, чтобы никто параллельно не трогал
SELECT balance
FROM accounts
WHERE name = 'Bob'
FOR UPDATE;

-- Проверка условий
DO $$
DECLARE
    bob_balance DECIMAL(10,2);
BEGIN
    SELECT balance INTO bob_balance
    FROM accounts
    WHERE name = 'Bob';

    IF bob_balance < 200 THEN
        RAISE EXCEPTION 'Insufficient funds: Bob has %, needs 200', bob_balance;
    ELSE
        UPDATE accounts
        SET balance = balance - 200
        WHERE name = 'Bob';

        UPDATE accounts
        SET balance = balance + 200
        WHERE name = 'Wally';
    END IF;
END $$;

COMMIT;

-- 4.2
BEGIN;

-- 1. Insert
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta Lab', 5.00);

SAVEPOINT sp1;  -- после вставки

-- 2. Update
UPDATE products
SET price = 6.00
WHERE shop = 'Joe''s Shop' AND product = 'Fanta Lab';

SAVEPOINT sp2;  -- после изменения цены

-- 3. Delete
DELETE FROM products
WHERE shop = 'Joe''s Shop' AND product = 'Fanta Lab';

-- 4. Откат только до первого сейвпоинта
ROLLBACK TO sp1;

COMMIT;

SELECT * FROM products WHERE product = 'Fanta Lab';


-- 4.3
TRUNCATE accounts RESTART IDENTITY;

INSERT INTO accounts (name, balance) VALUES
('Shared', 300.00);


BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance FROM accounts WHERE name = 'Shared';  -- видит 300

-- решает снять 250
UPDATE accounts
SET balance = balance - 250
WHERE name = 'Shared';

-- не коммитит пока
-- можно поставить паузу

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance FROM accounts WHERE name = 'Shared';  -- тоже видит 300 (если не FOR UPDATE)

UPDATE accounts
SET balance = balance - 250
WHERE name = 'Shared';

COMMIT;

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM accounts
WHERE name = 'Shared'
FOR UPDATE;  -- блокируем строку

-- видит 300, снимает 250
UPDATE accounts
SET balance = balance - 250
WHERE name = 'Shared';

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM accounts
WHERE name = 'Shared'
FOR UPDATE;
-- этот SELECT будет ждать, пока T1 закоммитит

-- после коммита T1 баланс уже 50
-- тут можно проверить баланс и решить не снимать

-- 4.4
CREATE TABLE sells (
    shop VARCHAR(100),
    product VARCHAR(100),
    price DECIMAL(10,2)
);

INSERT INTO sells (shop, product, price) VALUES
('Joe''s Shop', 'A', 10.00),
('Joe''s Shop', 'B', 20.00),
('Joe''s Shop', 'C', 30.00);


-- Step 1
UPDATE sells
SET price = price + 20
WHERE shop = 'Joe''s Shop' AND product IN ('A', 'B');

-- где-то между этими апдейтами Sally лезет в данные

-- Step 2
UPDATE sells
SET price = price + 20
WHERE shop = 'Joe''s Shop' AND product = 'C';

SELECT MAX(price) AS max_price
FROM sells
WHERE shop = 'Joe''s Shop';

SELECT MIN(price) AS min_price
FROM sells
WHERE shop = 'Joe''s Shop';

BEGIN;

UPDATE sells
SET price = price + 20
WHERE shop = 'Joe''s Shop';

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT MAX(price) AS max_price
FROM sells
WHERE shop = 'Joe''s Shop';

SELECT MIN(price) AS min_price
FROM sells
WHERE shop = 'Joe''s Shop';

COMMIT;
















