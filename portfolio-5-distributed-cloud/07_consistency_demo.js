// Benchokz Bank Limited - Portfolio 5: consistency - how sure do we want to be that a write is safe?
// Use the replica-set connection. A write concern says how many servers must confirm a write.
db = db.getSiblingDB("benchokz_dist");

print("--- w:1  = only the primary confirms (fastest, but lost if the primary dies before copying) ---");
print(db.accounts.updateOne({ accountNumber: "0000000010" }, { $inc: { balance: 100 } }, { writeConcern: { w: 1 } }).acknowledged);

print("--- w:'majority' = most servers confirm (safer, slightly slower: what a bank should use) ---");
print(db.accounts.updateOne({ accountNumber: "0000000010" }, { $inc: { balance: 100 } }, { writeConcern: { w: "majority", wtimeout: 5000 } }).acknowledged);

print("--- w:3 with a server missing would wait. Here all 3 are up, so it succeeds ---");
print(db.accounts.updateOne({ accountNumber: "0000000010" }, { $inc: { balance: -200 } }, { writeConcern: { w: 3, wtimeout: 5000 } }).acknowledged);

print("--- Read with 'majority' read concern: only returns data that most servers have ---");
printjson(db.accounts.find({ accountNumber: "0000000010" }, { _id: 0 }).readConcern("majority").toArray());
