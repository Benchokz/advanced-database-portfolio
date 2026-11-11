// Benchokz Bank Limited - Portfolio 4: indexes and execution statistics in MongoDB
// Shows the same query BEFORE and AFTER adding an index, like Portfolio 2 did in PostgreSQL.
db = db.getSiblingDB("benchokz_nosql");

function stageOf(plan) {                       // list the plan stages, e.g. "COLLSCAN" or "FETCH > IXSCAN" (works for both explain formats)
  const found = (JSON.stringify(plan).match(/"stage":"([A-Z_]+)"/g) || []).map(x => x.slice(9, -1)).filter(x => x !== "sbe");
  return found.filter((x, i) => found.indexOf(x) === i).join(" > ");
}
function report(label, cursor) {
  const e = cursor.explain("executionStats");
  const s = e.executionStats;
  print(label + ":  plan = " + stageOf(e.queryPlanner.winningPlan) +
        " | docsExamined = " + s.totalDocsExamined + " | returned = " + s.nReturned + " | time = " + s.executionTimeMillis + " ms");
}

db.transactions.dropIndexes();                 // start with only the default _id index
print("indexes reset");

const q1 = () => db.transactions.find({ customerId: 777, status: "completed" }).sort({ createdAt: -1 });
const q2 = () => db.transactions.find({ channel: "pos", "metadata.merchant.category": "Fuel" });

print("===== BEFORE indexes =====");
report("Q1 customer 777 completed, newest first", q1());
report("Q2 POS fuel payments                   ", q2());

print("\n===== creating indexes =====");
print(db.transactions.createIndex({ customerId: 1, status: 1, createdAt: -1 }));
print(db.transactions.createIndex({ channel: 1, "metadata.merchant.category": 1 }));

print("\n===== AFTER indexes =====");
report("Q1 customer 777 completed, newest first", q1());
report("Q2 POS fuel payments                   ", q2());

print("\n===== indexes on the collection =====");
printjson(db.transactions.getIndexes().map(i => i.name));
