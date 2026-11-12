// Benchokz Bank Limited - Portfolio 5: show that data written once is copied to every server
// Connect Compass with the replica-set address (this one follows the primary automatically):
//   mongodb://localhost:27018,localhost:27019,localhost:27020/?replicaSet=benchokzRS
// Then paste this into the >_MONGOSH shell.

db = db.getSiblingDB("benchokz_dist");
db.accounts.drop();

print("--- Write 3 accounts to the PRIMARY. w:'majority' means: wait until most servers have a copy ---");
printjson(db.accounts.insertMany([
  { accountNumber: "0000000010", owner: "Chinedu Okafor", balance: 250000 },
  { accountNumber: "0000000020", owner: "Aisha Chukwu",   balance: 480000 },
  { accountNumber: "0000000030", owner: "Tunde Bello",    balance: 90000  }
], { writeConcern: { w: "majority", wtimeout: 5000 } }).acknowledged);

print("--- Read the same data from a SECONDARY (a copy on another server) ---");
db.getMongo().setReadPref("secondary");
print("documents seen on a secondary: " + db.accounts.countDocuments());
printjson(db.accounts.find({}, { _id: 0 }).toArray());
db.getMongo().setReadPref("primary");

print("--- Try to write directly to a secondary: this is not allowed (only the primary accepts writes) ---");
print("Connect Compass to mongodb://localhost:27019/?directConnection=true and run: db.getSiblingDB('benchokz_dist').accounts.insertOne({x:1})");
