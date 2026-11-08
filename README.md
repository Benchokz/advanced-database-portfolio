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
- `portfolio-4-nosql/` - MongoDB model and implementation
- `portfolio-5-distributed-cloud/` - replication, sharding, availability

## Tools
PostgreSQL (Docker), MongoDB (Docker), Docker Compose, DBeaver, dbdiagram.io, Git.

## AI Use Declaration
<Complete at the end: tool used, what it was used for, how you reviewed and tested the output.>
