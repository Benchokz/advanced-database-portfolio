-- Portfolio 3, Demo 1: a successful transfer (COMMIT)
-- Run 01_setup_demo.sql first. Transfers 10,000 from DEMO000001 to DEMO000002.
-- All the steps inside BEGIN ... COMMIT succeed together, or none of them do.

BEGIN;

UPDATE accounts SET balance = balance - 10000 WHERE account_number = 'DEMO000001';
UPDATE accounts SET balance = balance + 10000 WHERE account_number = 'DEMO000002';

INSERT INTO transactions (account_id, txn_type, amount, balance_after, status, reference, description)
SELECT account_id, 'transfer_out', 10000, balance, 'completed', 'DEMO-T1-OUT', 'Demo transfer to DEMO000002'
FROM accounts WHERE account_number = 'DEMO000001';

INSERT INTO transactions (account_id, txn_type, amount, balance_after, status, reference, description)
SELECT account_id, 'transfer_in', 10000, balance, 'completed', 'DEMO-T1-IN', 'Demo transfer from DEMO000001'
FROM accounts WHERE account_number = 'DEMO000002';

INSERT INTO transfers (from_account_id, to_account_id, amount, status, debit_txn_id, credit_txn_id)
SELECT a.account_id, b.account_id, 10000, 'completed', o.transaction_id, i.transaction_id
FROM accounts a, accounts b, transactions o, transactions i
WHERE a.account_number = 'DEMO000001' AND b.account_number = 'DEMO000002'
  AND o.reference = 'DEMO-T1-OUT' AND i.reference = 'DEMO-T1-IN';

COMMIT;

-- Check (run these after COMMIT; screenshot the results)
SELECT account_number, balance FROM accounts WHERE account_number LIKE 'DEMO%' ORDER BY account_number;
SELECT SUM(balance) AS total_money FROM accounts WHERE account_number LIKE 'DEMO%';   -- still 150,000
SELECT reference, txn_type, amount, balance_after, status FROM transactions WHERE reference LIKE 'DEMO-T1%';
