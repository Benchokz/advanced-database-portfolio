-- Portfolio 3, Demo 5: isolation levels
-- Needs TWO Query Tool tabs: Session A and Session B. Run 01_setup_demo.sql before each part.
-- Run each step on its own (highlight it, press F5), in exactly this order.

-- ===== Part 1: no dirty reads (the default READ COMMITTED level) =====
-- 1. SESSION A
BEGIN;
UPDATE accounts SET balance = balance - 10000 WHERE account_number = 'DEMO000001';   -- not committed yet
-- 2. SESSION B: does B see A's uncommitted change? No: it still sees 100,000
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';
-- 3. SESSION A
ROLLBACK;


-- ===== Part 2: non-repeatable read at READ COMMITTED =====
-- (run 01_setup_demo.sql again first)
-- 1. SESSION A
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';     -- 100,000
-- 2. SESSION B: change the balance and commit (one statement, no BEGIN needed)
UPDATE accounts SET balance = balance - 10000 WHERE account_number = 'DEMO000001';
-- 3. SESSION A: same query again, but the answer CHANGED to 90,000 inside one transaction
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';
COMMIT;


-- ===== Part 3: REPEATABLE READ fixes it =====
-- (run 01_setup_demo.sql again first)
-- 1. SESSION A
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';     -- 100,000
-- 2. SESSION B
UPDATE accounts SET balance = balance - 10000 WHERE account_number = 'DEMO000001';
-- 3. SESSION A: still 100,000. A keeps seeing the data as it was when its transaction began
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';
COMMIT;
-- 4. SESSION A: after COMMIT, the new value 90,000 is visible
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';


-- ===== Part 4: REPEATABLE READ stops conflicting writes =====
-- (run 01_setup_demo.sql again first)
-- 1. SESSION A
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';
-- 2. SESSION B
UPDATE accounts SET balance = balance - 10000 WHERE account_number = 'DEMO000001';
-- 3. SESSION A: tries to change the same row, which B already changed since A began.
--    PostgreSQL refuses: "could not serialize access due to concurrent update"
UPDATE accounts SET balance = balance - 5000 WHERE account_number = 'DEMO000001';
-- 4. SESSION A: roll back (a real application would retry the transaction)
ROLLBACK;
