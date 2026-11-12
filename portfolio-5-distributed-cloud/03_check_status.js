// Benchokz Bank Limited - Portfolio 5: show the state of the replica set
// Use this any time. It prints one line per server: its name, its role and its health.
rs.status().members.forEach(m =>
  print(m.name + "  ->  " + m.stateStr + "   (health: " + m.health + ")"));
