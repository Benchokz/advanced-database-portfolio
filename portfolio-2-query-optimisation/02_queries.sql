-- Benchokz Bank Limited - Portfolio 2: business queries (run one at a time, screenshot results)

-- Q1: Statement - last 90 days of transactions for one account
SELECT transaction_id, txn_type, amount, status, created_at
FROM transactions
WHERE account_id = 4521
  AND created_at >= NOW() - INTERVAL '90 days'
ORDER BY created_at DESC;

-- Q2: Top 10 customers by completed transaction value in the last 30 days (3-table join + aggregate)
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(*) AS txn_count, SUM(t.amount) AS total_value
FROM customers c
JOIN accounts a     ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id  = a.account_id
WHERE t.status = 'completed'
  AND t.created_at >= NOW() - INTERVAL '30 days'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_value DESC
LIMIT 10;

-- Q3: All accounts owned by one customer
SELECT account_id, account_number, balance, status
FROM accounts
WHERE customer_id = 777;

-- Q4: Audit - failed transactions per day in the last 30 days
SELECT created_at::date AS day, COUNT(*) AS failed_count
FROM transactions
WHERE status = 'failed'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY created_at::date
ORDER BY day;

-- Q5: Transfers involving one account (as sender or receiver)
SELECT transfer_id, from_account_id, to_account_id, amount, status, initiated_at
FROM transfers
WHERE from_account_id = 4521 OR to_account_id = 4521
ORDER BY initiated_at DESC;
