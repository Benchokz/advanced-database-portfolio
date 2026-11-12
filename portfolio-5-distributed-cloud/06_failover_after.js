// Benchokz Bank Limited - Portfolio 5: after the primary stepped down
// A different server should now be PRIMARY, the data must still be there, and writes must still work.
db = db.getSiblingDB("benchokz_dist");
rs.status().members.forEach(m => print("AFTER:  " + m.name + "  ->  " + m.stateStr));
print("new write acknowledged: " + db.accounts.updateOne(
  { accountNumber: "0000000040" },
  { $set: { owner: "Written after failover", balance: 1000 } },
  { upsert: true, writeConcern: { w: "majority", wtimeout: 5000 } }).acknowledged);
print("accounts now: " + db.accounts.countDocuments() + "  (expected 4)");
