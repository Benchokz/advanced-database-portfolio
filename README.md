# MIT 8103 Advanced Database Systems - Portfolio

**Student:** Chukwuebuka Arueze | **Student ID:** 301912110

## Selected Case Study: Benchokz Bank Limited (simulated retail bank / fintech platform)

**Scenario:** Benchokz Bank Limited is a simulated retail bank offering savings, current and
wallet accounts to individuals through branches and a mobile app.

**Nature of the system:** An operational (OLTP) banking database that records customers,
accounts, deposits, withdrawals and fund transfers, with a full transaction log for audit.

**Users of the database:**
- Customers (via the mobile app): view balances, make transfers
- Tellers / branch staff: open accounts, process deposits and withdrawals
- Auditors / compliance officers: audit balances and review transaction history
- Operations staff: reverse failed transactions

**Major data stored:** customers, branches, account types, accounts, transactions, transfers.

**Key operations supported:** open an account, deposit, withdraw, transfer funds between
accounts, reverse a failed transaction, audit account balances, retrieve statements.

## Repository structure
- `portfolio-1-database-design/` - ER diagram, schema, normalisation
- `portfolio-2-query-optimisation/` - queries, execution plans, indexing
- `portfolio-3-transactions-concurrency/` - commit, rollback, isolation, locking
- `portfolio-4-nosql/` - MongoDB document model, queries, aggregations, indexes
- `portfolio-5-distributed-cloud/` - replica set, failover, consistency, sharding and cloud discussion

## Tools
PostgreSQL 18, pgAdmin 4, MongoDB 8.2, MongoDB Compass (with its built-in mongosh shell), PowerShell, dbdiagram.io, Visual Studio Code, Git and GitHub.

## AI Use Declaration
**Tool used:** Claude (an AI assistant by Anthropic).

**Used for:**
- Portfolio 1: drafting the database schema, the ER diagram source and the normalisation write-up.
- Portfolio 2: generating the fake-data script, the queries, the indexing scripts and the README.
- Portfolio 3: generating the transaction, rollback, lost-update, locking and isolation-level scripts and the README.
- Portfolio 4: designing the MongoDB document model, generating the data, query, aggregation and index scripts, and drafting the README.
- Portfolio 5: planning the replica-set setup, writing the PowerShell and mongosh scripts, and drafting the explanations of replication, consistency, sharding and cloud deployment.
- Explaining concepts and giving git/VS Code commands.

**How verified:** I ran every script myself (pgAdmin for PostgreSQL, MongoDB Compass and PowerShell for MongoDB), took the screenshots myself, and checked that the results match what each README describes. Where a first attempt gave an unexpected result (for example, the failover test in Portfolio 5), I repeated it and kept the corrected evidence. The discussions, reflections and final conclusions are my own understanding.
