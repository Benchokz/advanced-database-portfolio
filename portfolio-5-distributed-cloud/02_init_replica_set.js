// Benchokz Bank Limited - Portfolio 5: turn the 3 servers into one replica set
// Connect Compass to: mongodb://localhost:27018/?directConnection=true   (only for this one step)
// Then paste this into the >_MONGOSH shell.

rs.initiate({
  _id: "benchokzRS",
  members: [
    { _id: 0, host: "localhost:27018", priority: 2 },   // preferred primary
    { _id: 1, host: "localhost:27019" },
    { _id: 2, host: "localhost:27020" }
  ]
});
// Wait about 10 seconds, then run 03_check_status.js to see who became PRIMARY.
