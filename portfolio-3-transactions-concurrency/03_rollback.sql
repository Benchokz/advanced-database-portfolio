-- Portfolio 3, Demo 2: ROLLBACK
-- Run 01_setup_demo.sql first. Run each numbered step on its own (highlight it, press F5).

-- ===== Part A: a manual ROLLBACK =====
-- A1
BEGIN;
-- A2: take 5,000 out of DEMO000001 (inside the open transaction)
UPDATE accounts SET balance = balance - 5000 WHERE account_number = 'DEMO000001';
-- A3: inside the transaction you can see the change (95,000)
SELECT account_number, balance FROM accounts WHERE account_number = 'DEMO000001';
-- A4: change of mind - undo everything
ROLLBACK;
-- A5: the balance is back to 100,000
SELECT account_number, balance FROM accounts WHERE account_number = 'DEMO000001';


-- ===== Part B: a failed transfer is rolled back (atomicity) =====
-- DEMO000001 has only 100,000, so sending 500,000 must fail.
-- B1
BEGIN;
-- B2: the credit to the receiver works (receiver would show 550,000 inside this transaction)
UPDATE accounts SET balance = balance + 500000 WHERE account_number = 'DEMO000002';
-- B3: the debit FAILS: the CHECK (balance >= 0) rule blocks it, and you see an error
UPDATE accounts SET balance = balance - 500000 WHERE account_number = 'DEMO000001';
-- B4: the transaction is now broken, so roll it back
ROLLBACK;
-- B5: the receiver's credit was undone too. Balances are 100,000 and 50,000 again.
SELECT account_number, balance FROM accounts WHERE account_number LIKE 'DEMO%' ORDER BY account_number;
