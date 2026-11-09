-- Removes the Portfolio 2 indexes so you can re-capture "before" plans if needed.
DROP INDEX IF EXISTS idx_transactions_account_created, idx_transactions_created,
  idx_accounts_customer, idx_transactions_failed, idx_transfers_from, idx_transfers_to;
ANALYZE;
