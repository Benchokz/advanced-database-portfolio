-- Portfolio 3, Demo 6: reversing a transfer (a bank operation from the case study)
-- Run 01_setup_demo.sql, then 02_commit_transfer.sql, THEN this script.
-- It undoes the 10,000 transfer, keeping the original records and adding reversal records.

BEGIN;

UPDATE accounts SET balance = balance + 10000 WHERE account_number = 'DEMO000001';
UPDATE accounts SET balance = balance - 10000 WHERE account_number = 'DEMO000002';

INSERT INTO transactions (account_id, txn_type, amount, balance_after, status, reference, reverses_txn_id, description)
SELECT a.account_id, 'reversal', 10000, a.balance, 'completed', 'DEMO-T1-REV-OUT', o.transaction_id, 'Reversal of DEMO-T1-OUT'
FROM accounts a, transactions o WHERE a.account_number = 'DEMO000001' AND o.reference = 'DEMO-T1-OUT';

INSERT INTO transactions (account_id, txn_type, amount, balance_after, status, reference, reverses_txn_id, description)
SELECT a.account_id, 'reversal', 10000, a.balance, 'completed', 'DEMO-T1-REV-IN', i.transaction_id, 'Reversal of DEMO-T1-IN'
FROM accounts a, transactions i WHERE a.account_number = 'DEMO000002' AND i.reference = 'DEMO-T1-IN';

UPDATE transactions SET status = 'reversed' WHERE reference IN ('DEMO-T1-OUT', 'DEMO-T1-IN');
UPDATE transfers SET status = 'reversed'
WHERE debit_txn_id = (SELECT transaction_id FROM transactions WHERE reference = 'DEMO-T1-OUT');

COMMIT;

-- Check (screenshot): balances back to 100,000 and 50,000; original rows marked 'reversed'
SELECT account_number, balance FROM accounts WHERE account_number LIKE 'DEMO%' ORDER BY account_number;
SELECT reference, txn_type, amount, status, reverses_txn_id FROM transactions WHERE reference LIKE 'DEMO-T1%' ORDER BY transaction_id;
