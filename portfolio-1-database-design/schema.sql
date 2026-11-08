-- Benchokz Bank Limited - Portfolio 1 schema (PostgreSQL)
DROP TABLE IF EXISTS transfers, transactions, accounts, account_types, branches, customers CASCADE;

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(20)  NOT NULL UNIQUE,
    date_of_birth DATE         NOT NULL,
    kyc_status    VARCHAR(10)  NOT NULL DEFAULT 'pending'
                  CHECK (kyc_status IN ('pending', 'verified', 'rejected')),
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    CHECK (date_of_birth <= DATE '2008-01-01')
);

CREATE TABLE branches (
    branch_id   SERIAL PRIMARY KEY,
    branch_name VARCHAR(80) NOT NULL UNIQUE,
    city        VARCHAR(60) NOT NULL,
    state       VARCHAR(60) NOT NULL
);

CREATE TABLE account_types (
    account_type_id SERIAL PRIMARY KEY,
    type_name       VARCHAR(30)   NOT NULL UNIQUE,   -- savings, current, wallet
    min_balance     NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (min_balance >= 0),
    interest_rate   NUMERIC(5,2)  NOT NULL DEFAULT 0 CHECK (interest_rate >= 0)
);

CREATE TABLE accounts (
    account_id      SERIAL PRIMARY KEY,
    account_number  CHAR(10)      NOT NULL UNIQUE,
    customer_id     INT           NOT NULL REFERENCES customers(customer_id),
    branch_id       INT           NOT NULL REFERENCES branches(branch_id),
    account_type_id INT           NOT NULL REFERENCES account_types(account_type_id),
    balance         NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status          VARCHAR(10)   NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'frozen', 'closed')),
    opened_at       TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE TABLE transactions (
    transaction_id   BIGSERIAL PRIMARY KEY,
    account_id       INT           NOT NULL REFERENCES accounts(account_id),
    txn_type         VARCHAR(15)   NOT NULL
                     CHECK (txn_type IN ('deposit', 'withdrawal', 'transfer_in', 'transfer_out', 'reversal')),
    amount           NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    balance_after    NUMERIC(15,2) NOT NULL CHECK (balance_after >= 0),
    status           VARCHAR(10)   NOT NULL DEFAULT 'completed'
                     CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    reference        VARCHAR(40)   NOT NULL UNIQUE,
    reverses_txn_id  BIGINT        REFERENCES transactions(transaction_id),  -- set only for reversals
    description      VARCHAR(200),
    created_at       TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE TABLE transfers (
    transfer_id     BIGSERIAL PRIMARY KEY,
    from_account_id INT           NOT NULL REFERENCES accounts(account_id),
    to_account_id   INT           NOT NULL REFERENCES accounts(account_id),
    amount          NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    status          VARCHAR(10)   NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    debit_txn_id    BIGINT        REFERENCES transactions(transaction_id),
    credit_txn_id   BIGINT        REFERENCES transactions(transaction_id),
    initiated_at    TIMESTAMP     NOT NULL DEFAULT NOW(),
    CHECK (from_account_id <> to_account_id)
);

-- Starter reference data
INSERT INTO branches (branch_name, city, state) VALUES
  ('Onitsha Main', 'Onitsha', 'Anambra'),
  ('Ikeja Central', 'Ikeja', 'Lagos');
INSERT INTO account_types (type_name, min_balance, interest_rate) VALUES
  ('savings', 1000, 3.50), ('current', 0, 0), ('wallet', 0, 0);
