MIT 8103 ADVANCED DATABASE SYSTEMS - CONTINUOUS ASSESSMENT (SEPTEMBER COHORT 2026)
README

Student:     Chukwuebuka Arueze
Student ID:  301912110
Email:       c.arueze2110@miva.edu.ng
GitHub repository: https://github.com/Benchokz/advanced-database-portfolio

----------------------------------------------------------------------
SELECTED CASE STUDY: BENCHOKZ BANK LIMITED (simulated retail bank / fintech platform)
----------------------------------------------------------------------
Scenario: Benchokz Bank Limited is a simulated retail bank offering savings, current
and wallet accounts to individuals through branches and a mobile app.

Nature of the system: An operational banking database of the OLTP (Online Transaction Processing) kind that records customers,
accounts, deposits, withdrawals and fund transfers, with a full transaction log for audit.

Users of the database:
  - Customers (via the mobile app): view balances, make transfers
  - Tellers / branch staff: open accounts, process deposits and withdrawals
  - Auditors / compliance officers: audit balances and review transaction history
  - Operations staff: reverse failed transactions

Major data stored: customers, branches, account types, accounts, transactions, transfers.

Key operations supported: open an account, deposit, withdraw, transfer funds between
accounts, reverse a failed transaction, audit account balances, retrieve statements.

The same case study is used in all five portfolios.

----------------------------------------------------------------------
SUMMARY OF THE FIVE PORTFOLIOS
----------------------------------------------------------------------
1. Database Design and Modelling
   Designed 6 PostgreSQL tables (customers, branches, account_types, accounts,
   transactions, transfers) with primary keys, foreign keys, UNIQUE and CHECK rules,
   drew the ER diagram, and explained normalisation to third normal form.
   Result: valid data is accepted; bad data is rejected by CHECK and foreign key rules.

2. Query Processing and Optimisation
   Loaded 500,000 fake transactions, ran 5 bank queries with EXPLAIN ANALYZE, then
   added indexes and ran them again.
   Result: every query got faster; the best went from 274 ms to 0.15 ms.

3. Transactions and Concurrency
   Showed COMMIT, ROLLBACK, a transfer reversal, the lost update problem, row locking
   (SELECT ... FOR UPDATE) and isolation levels (READ COMMITTED and REPEATABLE READ).
   Result: without locking the balance ended at 80,000 (wrong); with locking it
   ended at 50,000 (correct).

4. NoSQL and Advanced Data Models
   Modelled the bank as MongoDB documents (customers with embedded accounts, and
   transactions with channel-specific metadata), loaded 5,000 customers and 50,000
   transactions, and ran queries, aggregation pipelines and indexes.
   Result: indexes cut the documents read from 50,000 to 8 and the time from 167 ms
   to 14 ms.

5. Distributed and Cloud Database Exercise
   Built a 3-server MongoDB replica set, showed replication, failover and write
   concerns, and discussed sharding, consistency, availability and cloud deployment.
   Result: after the primary stepped down, another server took over and a new write
   was still accepted.

----------------------------------------------------------------------
HOW TO READ THE SUBMISSION
----------------------------------------------------------------------
The zipped folder contains the whole repository:
  portfolio-1-database-design/
  portfolio-2-query-optimisation/
  portfolio-3-transactions-concurrency/
  portfolio-4-nosql/
  portfolio-5-distributed-cloud/
  README.md
plus the 2-3 page documentation (Arueze_Chukwuebuka_301912110_Technical_Documentation.pdf).

Start with README.md, then open each portfolio folder and read its README.md.
Screenshots are in each folder's "screenshots" subfolder. Scripts are numbered in the
order they were run. The same content is on GitHub at the link above.

----------------------------------------------------------------------
TOOLS
----------------------------------------------------------------------
PostgreSQL 18, pgAdmin 4, MongoDB 8.2, MongoDB Compass (with its built-in mongosh
shell), PowerShell, dbdiagram.io, Visual Studio Code, Git and GitHub.

----------------------------------------------------------------------
AI USE DECLARATION
----------------------------------------------------------------------
Tool used: Claude (an AI assistant by Anthropic).

Used for:
  - Portfolio 1: drafting the database schema, the ER diagram source and the
    normalisation write-up.
  - Portfolio 2: generating the fake-data script, the queries, the indexing scripts
    and the README.
  - Portfolio 3: generating the transaction, rollback, lost-update, locking and
    isolation-level scripts and the README.
  - Portfolio 4: designing the MongoDB document model, generating the data, query,
    aggregation and index scripts, and drafting the README.
  - Portfolio 5: planning the replica-set setup, writing the PowerShell and mongosh
    scripts, and drafting the explanations of replication, consistency, sharding and
    cloud deployment.
  - Explaining concepts and giving git/VS Code commands.

How verified: I ran every script myself (pgAdmin for PostgreSQL, MongoDB Compass and
PowerShell for MongoDB), took the screenshots myself, and checked that the results
match what each README describes. Where a first attempt gave an unexpected result (for
example, the failover test in Portfolio 5), I repeated it and kept the corrected
evidence. The discussions, reflections and final conclusions are my own understanding.
