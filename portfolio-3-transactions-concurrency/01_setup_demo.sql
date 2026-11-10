-- Benchokz Bank Limited - Portfolio 3: demo accounts with known balances
-- Safe to run again at any time: it removes the old demo rows and recreates them,
-- which resets both balances to their starting values.

DELETE FROM transfers
 WHERE from_account_id IN (SELECT account_id FROM accounts WHERE account_number LIKE 'DEMO%')
    OR to_account_id   IN (SELECT account_id FROM accounts WHERE account_number LIKE 'DEMO%');
DELETE FROM transactions
 WHERE account_id IN (SELECT account_id FROM accounts WHERE account_number LIKE 'DEMO%');
DELETE FROM accounts  WHERE account_number LIKE 'DEMO%';
DELETE FROM customers WHERE email LIKE 'demo.%@example.com';

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, kyc_status) VALUES
  ('Demo', 'Sender',   'demo.sender@example.com',   '09000000001', '1990-01-01', 'verified'),
  ('Demo', 'Receiver', 'demo.receiver@example.com', '09000000002', '1990-01-01', 'verified');

INSERT INTO accounts (account_number, customer_id, branch_id, account_type_id, balance)
SELECT 'DEMO000001', customer_id, 1, 2, 100000 FROM customers WHERE email = 'demo.sender@example.com';
INSERT INTO accounts (account_number, customer_id, branch_id, account_type_id, balance)
SELECT 'DEMO000002', customer_id, 1, 2, 50000 FROM customers WHERE email = 'demo.receiver@example.com';

-- Starting position: DEMO000001 = 100,000 and DEMO000002 = 50,000 (total 150,000)
SELECT account_number, balance FROM accounts WHERE account_number LIKE 'DEMO%' ORDER BY account_number;
