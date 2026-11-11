// Benchokz Bank Limited - Portfolio 4: build the MongoDB database with fake data
// Run in mongosh / MongoDB Compass shell. WARNING: drops and recreates database "benchokz_nosql".
// Creates 2 collections:
//   customers    (5,000 docs)  - one document per customer, with their accounts EMBEDDED inside
//   transactions (50,000 docs) - one document per transaction, with channel-specific details in "metadata"

db = db.getSiblingDB("benchokz_nosql");
print("dropped: " + db.dropDatabase().ok);

const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];
const rand = (min, max) => Math.floor(min + Math.random() * (max - min + 1));
const money = (min, max) => Math.round((min + Math.random() * (max - min)) * 100) / 100;
const daysAgo = (d) => new Date(Date.now() - Math.random() * d * 24 * 3600 * 1000);

const firstNames = ["Chinedu","Amaka","Tunde","Ngozi","Ibrahim","Fatima","Emeka","Aisha","Segun","Chioma","Obinna","Zainab","Kelechi","Bola","Uche","Hauwa","Ifeanyi","Folake","Musa","Nneka"];
const lastNames  = ["Okafor","Adeyemi","Bello","Eze","Mohammed","Nwosu","Balogun","Abubakar","Okonkwo","Ibrahim","Chukwu","Lawal","Udoh","Danjuma","Ogunleye","Obi","Yusuf","Afolabi","Nnamdi","Sani"];
const branches = [
  { name: "Onitsha Main",       city: "Onitsha",       state: "Anambra" },
  { name: "Ikeja Central",      city: "Ikeja",         state: "Lagos" },
  { name: "Port Harcourt GRA",  city: "Port Harcourt", state: "Rivers" },
  { name: "Abuja Wuse",         city: "Abuja",         state: "FCT" },
  { name: "Enugu Independence", city: "Enugu",         state: "Enugu" },
  { name: "Kano Central",       city: "Kano",          state: "Kano" }
];
const accountTypes = ["savings", "current", "wallet"];

// ---------- customers (accounts embedded) ----------
const NUM_CUSTOMERS = 5000;
const customers = [];
for (let i = 1; i <= NUM_CUSTOMERS; i++) {
  const branch = pick(branches);
  const accounts = [];
  const n = rand(1, 3);
  for (let a = 0; a < n; a++) {
    accounts.push({
      accountNumber: String(i * 10 + a).padStart(10, "0"),
      type: pick(accountTypes),
      branch: branch.name,
      balance: money(0, 5000000),
      status: pick(["active","active","active","active","frozen","closed"])
    });
  }
  const c = {
    customerId: i,
    firstName: pick(firstNames),
    lastName: pick(lastNames),
    email: "customer" + i + "@example.com",
    phone: "080" + String(i).padStart(8, "0"),
    kycStatus: pick(["verified","verified","verified","pending","rejected"]),
    address: { city: branch.city, state: branch.state },
    createdAt: daysAgo(730),
    accounts: accounts
  };
  // Optional fields: only SOME customers have them (no empty columns needed, unlike SQL)
  if (Math.random() < 0.4) c.preferences = { language: pick(["en","ig","yo","ha"]), statementDelivery: pick(["email","sms","paper"]) };
  if (Math.random() < 0.15) c.nextOfKin = { name: pick(firstNames) + " " + pick(lastNames), relationship: pick(["spouse","parent","sibling"]) };
  customers.push(c);
}
print("customers inserted: " + db.customers.insertMany(customers).insertedCount);

// ---------- transactions (channel-specific metadata) ----------
const channels = ["mobile_app","mobile_app","mobile_app","web","atm","pos","pos","branch"];
const merchants = [
  { name: "ShopRite", category: "Groceries" }, { name: "Jumia Food", category: "Food" },
  { name: "Total Energies", category: "Fuel" }, { name: "MTN Airtime", category: "Telecom" },
  { name: "DSTV", category: "Entertainment" }, { name: "Medplus", category: "Health" }
];

function metadataFor(channel) {
  switch (channel) {
    case "mobile_app": return { device: { os: pick(["Android","iOS"]), model: pick(["Tecno Spark","Samsung A14","iPhone 13","Infinix Hot"]), appVersion: pick(["3.1.0","3.2.1","4.0.0"]) }, ip: "102.89." + rand(0,255) + "." + rand(1,254), location: { city: pick(branches).city } };
    case "web":        return { browser: pick(["Chrome","Firefox","Safari","Edge"]), ip: "197.210." + rand(0,255) + "." + rand(1,254) };
    case "atm":        return { atmId: "ATM" + rand(100, 999), location: { city: pick(branches).city, state: pick(branches).state }, cardLast4: String(rand(1000, 9999)) };
    case "pos":        return { merchant: pick(merchants), terminalId: "T" + rand(10000, 99999), cardLast4: String(rand(1000, 9999)) };
    case "branch":     return { tellerId: "TLR" + rand(1, 40), branchName: pick(branches).name };
  }
}

const NUM_TXNS = 50000;
let batch = [];
for (let i = 1; i <= NUM_TXNS; i++) {
  const cust = customers[rand(0, NUM_CUSTOMERS - 1)];
  const acct = pick(cust.accounts);
  const channel = pick(channels);
  const type = pick(["deposit","withdrawal","transfer_out","transfer_in","payment"]);
  const t = {
    txnRef: "NTX" + String(i).padStart(9, "0"),
    customerId: cust.customerId,
    accountNumber: acct.accountNumber,
    type: type,
    amount: money(100, 500000),
    currency: "NGN",
    status: pick(["completed","completed","completed","completed","completed","completed","completed","failed","pending","reversed"]),
    channel: channel,
    createdAt: daysAgo(365),
    metadata: metadataFor(channel)
  };
  if (type === "transfer_out" || type === "transfer_in") {
    t.counterparty = { name: pick(firstNames) + " " + pick(lastNames), bank: pick(["GTBank","Access","Zenith","UBA","First Bank"]), accountNumber: String(rand(1000000000, 9999999999)) };
  }
  if (Math.random() < 0.05) t.tags = ["flagged"];
  batch.push(t);
  if (batch.length === 5000) { db.transactions.insertMany(batch); batch = []; }
}
if (batch.length) db.transactions.insertMany(batch);

print("customers:    " + db.customers.countDocuments());
print("transactions: " + db.transactions.countDocuments());
printjson(db.customers.findOne({ customerId: 777 }));
printjson(db.transactions.findOne({ channel: "pos" }));
