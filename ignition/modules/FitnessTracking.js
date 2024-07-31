const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("FitnessTracking", (m) => {

  const FitnessTracking = m.contract("FitnessTracking", [], {
  });

  return { FitnessTracking };
});