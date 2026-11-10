-- Portfolio 3, Demo 4: the FIX using row locking (SELECT ... FOR UPDATE)
-- Needs TWO Query Tool tabs: Session A and Session B. Run 01_setup_demo.sql first.
-- Same story: A withdraws 30,000, B withdraws 20,000. Correct final balance: 50,000.
-- Run each step on its own (highlight it, press F5), in exactly this order.

-- 1. SESSION A: read the balance AND lock the row
BEGIN;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001' FOR UPDATE;   -- 100,000

-- 2. SESSION B: try to do the same. This one WAITS (pgAdmin keeps spinning)
--    because A holds the lock. Take a screenshot of B waiting, then go to step 3.
BEGIN;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001' FOR UPDATE;

-- 3. SESSION A: withdraw 30,000 and finish (this releases the lock)
UPDATE accounts SET balance = balance - 30000 WHERE account_number = 'DEMO000001';
COMMIT;

-- 4. SESSION B: its SELECT now finishes and shows the NEW balance, 70,000 (not 100,000)
--    Now B withdraws 20,000 from the up-to-date balance.
UPDATE accounts SET balance = balance - 20000 WHERE account_number = 'DEMO000001';
COMMIT;

-- 5. Either session: look at the result
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';
-- Result: 50,000. Both withdrawals were applied. Nothing was lost.
