-- Portfolio 3, Demo 3: the LOST UPDATE problem (no locking)
-- Needs TWO Query Tool tabs on benchokz_bank: call them Session A and Session B.
-- Run 01_setup_demo.sql first (in any tab). DEMO000001 starts at 100,000.
-- Story: two customers withdraw from the same account at the same time.
--   Session A withdraws 30,000.  Session B withdraws 20,000.  Correct final balance: 50,000.
-- Both sessions read the balance first, then write back a value they worked out themselves.
-- Run each step on its own (highlight it, press F5), in exactly this order.

-- 1. SESSION A
BEGIN;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';        -- 100,000

-- 2. SESSION B
BEGIN;
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';        -- also 100,000 (A has not committed)

-- 3. SESSION A (100,000 - 30,000 = 70,000)
UPDATE accounts SET balance = 70000 WHERE account_number = 'DEMO000001';
COMMIT;

-- 4. SESSION B (still thinks the balance is 100,000, so 100,000 - 20,000 = 80,000)
UPDATE accounts SET balance = 80000 WHERE account_number = 'DEMO000001';
COMMIT;

-- 5. Either session: look at the result
SELECT balance FROM accounts WHERE account_number = 'DEMO000001';
-- Result: 80,000. Both customers withdrew (50,000 in total), but only B's 20,000 shows.
-- A's withdrawal of 30,000 was LOST. The bank has 30,000 it should not have.
