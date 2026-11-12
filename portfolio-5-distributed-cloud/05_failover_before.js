// Benchokz Bank Limited - Portfolio 5: availability - what happens when the primary stops?
// Use the replica-set connection:
//   mongodb://localhost:27018,localhost:27019,localhost:27020/?replicaSet=benchokzRS
// STEP 1 (this file): paste it and screenshot the output ("before").
rs.status().members.forEach(m => print("BEFORE: " + m.name + "  ->  " + m.stateStr));

// STEP 2: type this one line on its own and press Enter (do not paste it with the code above):
//     rs.stepDown(300)
// The shell may show a "connection closed" message. That is normal: the primary just stepped down.
// STEP 3: wait about 10 seconds, then paste 06_failover_after.js.
