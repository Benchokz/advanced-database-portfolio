-- Benchokz Bank Limited - Portfolio 2: synthetic data generator (pure SQL, run in pgAdmin)
-- WARNING: empties customers, accounts, transactions and transfers, then refills them.
-- Reference tables (branches, account_types) are kept. Takes roughly 10-60 seconds.

TRUNCATE customers, accounts, transactions, transfers RESTART IDENTITY CASCADE;

-- More branches (existing ones are kept)
INSERT INTO branches (branch_name, city, state) VALUES
  ('Port Harcourt GRA', 'Port Harcourt', 'Rivers'),
  ('Abuja Wuse', 'Abuja', 'FCT'),
  ('Enugu Independence', 'Enugu', 'Enugu'),
  ('Kano Central', 'Kano', 'Kano'),
  ('Ibadan Ring Road', 'Ibadan', 'Oyo'),
  ('Benin Ugbowo', 'Benin City', 'Edo')
ON CONFLICT (branch_name) DO NOTHING;

-- 10,000 customers
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, kyc_status, created_at)
SELECT
  (ARRAY['Chinedu','Amaka','Tunde','Ngozi','Ibrahim','Fatima','Emeka','Aisha','Segun','Chioma',
         'Obinna','Zainab','Kelechi','Bola','Uche','Hauwa','Ifeanyi','Folake','Musa','Nneka'])[1 + floor(random()*20)::int],
  (ARRAY['Okafor','Adeyemi','Bello','Eze','Mohammed','Nwosu','Balogun','Abubakar','Okonkwo','Ibrahim',
         'Chukwu','Lawal','Udoh','Danjuma','Ogunleye','Obi','Yusuf','Afolabi','Nnamdi','Sani'])[1 + floor(random()*20)::int],
  'customer' || g || '@example.com',
  '080' || lpad(g::text, 8, '0'),
  DATE '1960-01-01' + floor(random() * 15000)::int,
  (ARRAY['verified','verified','verified','pending','rejected'])[1 + floor(random()*5)::int],
  NOW() - (random() * 730) * INTERVAL '1 day'
FROM generate_series(1, 10000) AS g;

-- 15,000 accounts (every customer gets at least one)
WITH b AS (SELECT array_agg(branch_id) AS ids FROM branches)
INSERT INTO accounts (account_number, customer_id, branch_id, account_type_id, balance, status, opened_at)
SELECT
  lpad(g::text, 10, '0'),
  CASE WHEN g <= 10000 THEN g ELSE 1 + floor(random()*10000)::int END,
  b.ids[1 + floor(random() * cardinality(b.ids))::int],
  1 + floor(random()*3)::int,
  round((random() * 5000000)::numeric, 2),
  (ARRAY['active','active','active','active','frozen','closed'])[1 + floor(random()*6)::int],
  NOW() - (random() * 700) * INTERVAL '1 day'
FROM generate_series(1, 15000) AS g, b;

-- 500,000 transactions (synthetic: balance_after is random, not a running balance)
INSERT INTO transactions (account_id, txn_type, amount, balance_after, status, reference, description, created_at)
SELECT
  1 + floor(random()*15000)::int,
  (ARRAY['deposit','withdrawal','transfer_in','transfer_out'])[1 + floor(random()*4)::int],
  round((100 + random() * 500000)::numeric, 2),
  round((random() * 5000000)::numeric, 2),
  (ARRAY['completed','completed','completed','completed','completed','completed','completed','completed','completed',
         'completed','completed','completed','completed','completed','completed','completed','completed','completed',
         'failed','failed','pending','pending','reversed'])[1 + floor(random()*23)::int],
  'TXN' || lpad(g::text, 12, '0'),
  'Synthetic transaction ' || g,
  NOW() - (random() * 365) * INTERVAL '1 day'
FROM generate_series(1, 500000) AS g;

-- 50,000 transfers between two different accounts
INSERT INTO transfers (from_account_id, to_account_id, amount, status, initiated_at)
SELECT f, ((f - 1 + 1 + floor(random()*14998)::int) % 15000) + 1, amt, st, ts
FROM (
  SELECT 1 + floor(random()*15000)::int AS f,
         round((100 + random() * 300000)::numeric, 2) AS amt,
         (ARRAY['completed','completed','completed','failed','pending','reversed'])[1 + floor(random()*6)::int] AS st,
         NOW() - (random() * 365) * INTERVAL '1 day' AS ts
  FROM generate_series(1, 50000)
) s;

ANALYZE;

-- Row counts for your screenshot
SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'transfers', COUNT(*) FROM transfers;
