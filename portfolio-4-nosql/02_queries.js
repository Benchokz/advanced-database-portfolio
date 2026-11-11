// Benchokz Bank Limited - Portfolio 4: queries (find, update, insert, delete)
// Run each numbered block on its own (paste it, or run the whole file) and screenshot the output.
db = db.getSiblingDB("benchokz_nosql");

print("--- Q1: one customer with all their accounts, in a single read (no join needed) ---");
printjson(db.customers.findOne({ email: "customer777@example.com" }, { _id: 0, customerId: 1, firstName: 1, lastName: 1, accounts: 1 }));

print("--- Q2: the 5 newest Android mobile-app transactions over 300,000 (query INSIDE nested metadata) ---");
printjson(db.transactions.find(
  { channel: "mobile_app", "metadata.device.os": "Android", amount: { $gt: 300000 } },
  { _id: 0, txnRef: 1, customerId: 1, type: 1, amount: 1, "metadata.device.model": 1, createdAt: 1 }
).sort({ createdAt: -1 }).limit(5).toArray());

print("--- Q3: POS payments at Groceries merchants over 400,000 ---");
printjson(db.transactions.find(
  { channel: "pos", "metadata.merchant.category": "Groceries", amount: { $gt: 400000 } },
  { _id: 0, txnRef: 1, amount: 1, "metadata.merchant.name": 1 }
).limit(5).toArray());

print("--- Q4: how many customers have at least one frozen account? (query inside an array) ---");
print(db.customers.countDocuments({ "accounts.status": "frozen" }));

print("--- Q5: INSERT a transaction from a brand-new channel (USSD) with different fields: no schema change needed ---");
db.transactions.insertOne({
  txnRef: "NTX-USSD-0001", customerId: 777, accountNumber: "0000007770", type: "payment",
  amount: 2500, currency: "NGN", status: "completed", channel: "ussd", createdAt: new Date(),
  metadata: { ussdCode: "*737#", network: "MTN", sessionId: "S-884213" }
});
printjson(db.transactions.findOne({ channel: "ussd" }, { _id: 0 }));

print("--- Q6: UPDATE - freeze the first account and add a note (only that array element changes) ---");
db.customers.updateOne(
  { customerId: 777 },
  { $set: { "accounts.0.status": "frozen" }, $push: { notes: { text: "Frozen for KYC review", at: new Date() } } }
);
printjson(db.customers.findOne({ customerId: 777 }, { _id: 0, customerId: 1, accounts: 1, notes: 1 }));

print("--- Q7: DELETE - remove the demo USSD transaction ---");
printjson(db.transactions.deleteOne({ txnRef: "NTX-USSD-0001" }));
print("remaining USSD transactions: " + db.transactions.countDocuments({ channel: "ussd" }));
