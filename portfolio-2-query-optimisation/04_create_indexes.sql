-- Benchokz Bank Limited - Portfolio 2: indexes (run AFTER capturing the "before" plans)

-- Q1, Q2: statements and date-range lookups per account
CREATE INDEX idx_transactions_account_created ON transactions (account_id, created_at DESC);

-- Q2: date-range filter across all accounts
CREATE INDEX idx_transactions_created ON transactions (created_at);

-- Q3: foreign key lookups (PostgreSQL does not index foreign keys automatically)
CREATE INDEX idx_accounts_customer ON accounts (customer_id);

-- Q4: partial index - only failed transactions, so it stays small
CREATE INDEX idx_transactions_failed ON transactions (created_at) WHERE status = 'failed';

-- Q5: both sides of the OR condition
CREATE INDEX idx_transfers_from ON transfers (from_account_id);
CREATE INDEX idx_transfers_to   ON transfers (to_account_id);

ANALYZE;
