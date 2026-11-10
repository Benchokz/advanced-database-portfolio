# Portfolio 3: Transactions and Concurrency

**Evidence provided:** Transaction examples showing commit, rollback, isolation, concurrency issue or control mechanism, and screenshots/output evidence.

**Case study:** Benchokz Bank Limited (a simulated bank). I used the same `benchokz_bank` database from Portfolios 1 and 2.

## In one minute
- A **transaction** groups several database steps so that **all of them happen, or none of them do**. This matters for a bank: when money moves, it must leave one account **and** arrive in the other.
- I showed a successful transfer (**COMMIT**), a failed one that is undone (**ROLLBACK**), and a transfer reversal.
- I then showed what goes wrong when **two people use the same account at the same time** (the **lost update** problem) and fixed it with **row locking**.
- Finally I compared **isolation levels**, which control what one transaction can see of another's changes.

## Files in this folder
| File | What it shows |
|---|---|
| `01_setup_demo.sql` | Creates two demo accounts with known balances. Running it again **resets** them |
| `02_commit_transfer.sql` | A successful transfer (COMMIT) |
| `03_rollback.sql` | A manual ROLLBACK, and a failed transfer that is rolled back |
| `04_lost_update_problem.sql` | The lost update problem (two sessions, no locking) |
| `05_lost_update_fix.sql` | The fix with `SELECT ... FOR UPDATE` (two sessions) |
| `06_isolation_levels.sql` | Isolation levels (two sessions) |
| `07_reverse_transfer.sql` | Reversing a completed transfer |
| `screenshots/` | My evidence for every demo |

## How I ran it
I used pgAdmin 4 (PostgreSQL 18) on `benchokz_bank`. For the demos that need **two sessions**, I opened **two Query Tool tabs**. Each tab has its own connection to the database, so I named them **Session A** and **Session B**. I ran each step on its own (highlight it, press F5) in the order written in the script. Before each demo I ran `01_setup_demo.sql` to reset the balances.

The demo accounts start like this:

| Account | Balance |
|---|---|
| DEMO000001 | 100,000 |
| DEMO000002 | 50,000 |
| **Total** | **150,000** |

![Starting balances](screenshots/01_setup_balances.png)

## Demo 1: COMMIT (a successful transfer)
`02_commit_transfer.sql` moves 10,000 from DEMO000001 to DEMO000002 inside one transaction (`BEGIN` ... `COMMIT`). It does five things together: two balance updates, two transaction records and one transfer record.

After the COMMIT:
- DEMO000001 = 90,000 and DEMO000002 = 60,000.
- The total is still **150,000**, so no money was created or lost.
- The two transaction records (`DEMO-T1-OUT` and `DEMO-T1-IN`) are saved as `completed`.

![Balances after commit](screenshots/02_commit_balances.png)
![Total after commit](screenshots/02_commit_total.png)
![Transaction records](screenshots/02_commit_transactions.png)

## Demo 2: ROLLBACK
`03_rollback.sql` has two parts.

**Part A: a manual rollback.** I took 5,000 from DEMO000001 inside a transaction, and the balance showed 95,000. I then ran `ROLLBACK`, and the balance went back to 100,000.

![Inside the transaction (95,000)](screenshots/03_rollback_a_inside.png)
![After rollback (100,000)](screenshots/03_rollback_a_after.png)

**Part B: a failed transfer is undone.** I tried to send 500,000 from DEMO000001, which only has 100,000. The credit to the receiver worked, but the debit **failed**, because the rule `CHECK (balance >= 0)` from Portfolio 1 blocked it. After `ROLLBACK`, the receiver's credit was **undone too**, and both balances were back to 100,000 and 50,000. This is **atomicity**: all or nothing.

![The error](screenshots/03_rollback_b_error.png)
![Balances after rollback](screenshots/03_rollback_b_after.png)

## Demo 3: the lost update problem (no locking)
Two customers withdraw from DEMO000001 at the same time. A withdraws 30,000 and B withdraws 20,000. The correct final balance is **50,000**.

Both sessions first **read** the balance (100,000), then each **writes** a new balance that it worked out on its own:
- A writes 70,000 (100,000 - 30,000).
- B still thinks the balance is 100,000, so it writes 80,000 (100,000 - 20,000).

**Result: 80,000.** A's withdrawal of 30,000 was **lost**. The bank is now 30,000 out of balance.

![Session A reads 100,000](screenshots/04_lost_update_a_read.png)
![Session B reads 100,000](screenshots/04_lost_update_b_read.png)
![Final balance: 80,000](screenshots/04_lost_update_result.png)

## Demo 4: the fix (row locking)
`05_lost_update_fix.sql` repeats the same story, but each session reads the balance with `SELECT ... FOR UPDATE`. This **locks the row**:
1. A reads and locks the row (100,000).
2. B tries the same, and **has to wait**, because A holds the lock. In pgAdmin the query shows "Waiting for the query to complete".
3. A withdraws 30,000 and commits. This releases the lock.
4. B's read now finishes and shows the **new** balance (70,000). B then withdraws 20,000.

**Result: 50,000.** Both withdrawals counted.

![A locks the row](screenshots/05_fix_a_locked.png)
![B is waiting](screenshots/05_fix_b_waiting.png)
![B sees the new balance (70,000)](screenshots/05_fix_b_after_wait.png)
![Final balance: 50,000](screenshots/05_fix_result.png)

| | Without locking | With `FOR UPDATE` |
|---|---|---|
| Final balance | 80,000 (wrong) | 50,000 (correct) |

## Demo 5: isolation levels
The isolation level decides what a transaction can see while other transactions are running. `06_isolation_levels.sql` has four parts.

| Part | Level | What I saw |
|---|---|---|
| 1 | READ COMMITTED (the default) | B could **not** see A's uncommitted change (it still saw 100,000). So PostgreSQL does not allow "dirty reads" |
| 2 | READ COMMITTED | A read the balance twice in one transaction and got **different answers** (100,000, then 90,000), because B committed in between. This is a **non-repeatable read** |
| 3 | REPEATABLE READ | A read 100,000 **both times**, even though B committed a change. A keeps seeing the data as it was when its transaction began. After A committed it saw 90,000 |
| 4 | REPEATABLE READ | A tried to change a row that B had already changed. PostgreSQL stopped it with the error **"could not serialize access due to concurrent update"**. A real application would roll back and retry |

Part 1 (no dirty read):

![Part 1](screenshots/06_p1_no_dirty_read.png)

Part 2 (READ COMMITTED: 100,000 then 90,000):

![Part 2, first read](screenshots/06_p2_first_read.png)
![Part 2, second read](screenshots/06_p2_second_read.png)

Part 3 (REPEATABLE READ: 100,000 twice, then 90,000 after commit):

![Part 3, first read](screenshots/06_p3_first_read.png)
![Part 3, second read](screenshots/06_p3_second_read.png)
![Part 3, after commit](screenshots/06_p3_after_commit.png)

Part 4 (the serialization error):

![Part 4](screenshots/06_p4_serialization_error.png)

## Demo 6: reversing a transfer
`07_reverse_transfer.sql` undoes the 10,000 transfer from Demo 1. It moves the money back, adds two `reversal` transaction records that point to the originals (using `reverses_txn_id` from Portfolio 1), and marks the original records as `reversed`. The old records are **kept**, so auditors have a full trail. This is the "reverse failed transactions" operation from my case study.

After the reversal, the balances are back to 100,000 and 50,000.

![Balances after reversal](screenshots/07_reverse_balances.png)
![Transaction records after reversal](screenshots/07_reverse_transactions.png)

## What I learned
- A transaction is **all or nothing**, which keeps a bank's money consistent.
- Reading a value and then writing back a result you calculated yourself is dangerous when other people can change the data in between.
- **Locking** (`FOR UPDATE`) fixes it by making the second person wait. The cost is that people may have to wait, so a lock should be held for as short a time as possible.
- Stronger isolation levels give more safety but can cause errors that the application has to handle by retrying.

## Reflection
The part that surprised me most was watching Session B wait. It looked as if the query had frozen, but it was simply waiting for Session A to finish, and it then returned the correct, up-to-date balance. Seeing the same account end at 80,000 without locking and 50,000 with locking made the lost update problem much easier to understand than reading about it.

**AI use:** Claude (an AI assistant by Anthropic) helped me generate the demo scripts and a draft of this README, and helped me understand how transactions, locking and isolation levels work. I ran every script myself in pgAdmin, using two query tabs for the concurrency demos, took all the screenshots, and checked that the results match what I describe.
