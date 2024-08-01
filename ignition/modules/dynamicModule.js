const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
require("dotenv").config();
const { INITIAL_OWNER } = process.env;


module.exports = buildModule("deployModule", (m) => {
  
  const contractDynamicNFT = m.contract("DynamicNFT", [INITIAL_OWNER]);
  const contractFitness = m.contract("FitnessTracking", [contractDynamicNFT, INITIAL_OWNER] );


  return { contractDynamicNFT, contractFitness };
});

