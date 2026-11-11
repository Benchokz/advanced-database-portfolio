// Benchokz Bank Limited - Portfolio 4: aggregation pipelines (MongoDB's version of GROUP BY / JOIN)
db = db.getSiblingDB("benchokz_nosql");

print("--- A1: number of transactions and total value per channel (completed only) ---");
printjson(db.transactions.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$channel", transactions: { $sum: 1 }, totalValue: { $sum: "$amount" } } },
  { $sort: { totalValue: -1 } },
  { $set: { totalValue: { $round: ["$totalValue", 2] } } }
]).toArray());

print("--- A2: top 10 customers by completed transaction value, last 30 days, with their names ($lookup = join) ---");
printjson(db.transactions.aggregate([
  { $match: { status: "completed", createdAt: { $gte: new Date(Date.now() - 30 * 24 * 3600 * 1000) } } },
  { $group: { _id: "$customerId", txnCount: { $sum: 1 }, totalValue: { $sum: "$amount" } } },
  { $sort: { totalValue: -1 } },
  { $limit: 10 },
  { $lookup: { from: "customers", localField: "_id", foreignField: "customerId", as: "customer" } },
  { $unwind: "$customer" },
  { $project: { _id: 0, customerId: "$_id", name: { $concat: ["$customer.firstName", " ", "$customer.lastName"] }, txnCount: 1, totalValue: { $round: ["$totalValue", 2] } } }
]).toArray());

print("--- A3: failed transactions per day, last 30 days (audit) ---");
printjson(db.transactions.aggregate([
  { $match: { status: "failed", createdAt: { $gte: new Date(Date.now() - 30 * 24 * 3600 * 1000) } } },
  { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, failedCount: { $sum: 1 } } },
  { $sort: { _id: 1 } },
  { $limit: 10 }
]).toArray());

print("--- A4: total balance held per city ($unwind opens up the embedded accounts array) ---");
printjson(db.customers.aggregate([
  { $unwind: "$accounts" },
  { $group: { _id: "$address.city", accounts: { $sum: 1 }, totalBalance: { $sum: "$accounts.balance" } } },
  { $sort: { totalBalance: -1 } },
  { $set: { totalBalance: { $round: ["$totalBalance", 2] } } }
]).toArray());

print("--- A5: which POS merchant categories get the most spending? (uses a field only POS documents have) ---");
printjson(db.transactions.aggregate([
  { $match: { channel: "pos" } },
  { $group: { _id: "$metadata.merchant.category", payments: { $sum: 1 }, totalSpent: { $sum: "$amount" } } },
  { $sort: { totalSpent: -1 } },
  { $set: { totalSpent: { $round: ["$totalSpent", 2] } } }
]).toArray());
