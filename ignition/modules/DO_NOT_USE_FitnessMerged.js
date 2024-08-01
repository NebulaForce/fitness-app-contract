const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

/*module.exports = buildModule("FitnessMergedModule", (m) => {
  // Define the contract ABI and contract name
  const fitnessMerged = m.contract("FitnessMerged", [
    "function safeMint(address to, uint256 tokenId, string memory tokenType) external",
    "function logMeasurement(uint8 _weight, uint8 _BMI, uint8 _bodyFat, uint8 _visceralFat, uint8 _bodyWater, uint8 _muscleMass, uint8 _metabolicAge, address _user) external",
    "function setGoal(uint8 _targetBodyFatPercent, uint8 _targetMuscleMassPercent, address _user) external",
    "function addCoach(address _coachAddress, uint8 _coachId) external",
    "function assignCoach(address _user, address _coach) external",
    "function getMeasurements(address _user) external view returns (Measurement[] memory)",
    "function getGoal(address _user) external view returns (Goal memory)"
  ]);

  // Deploy the contract
  const deployerAddress = "0x1B04132D7F2427cB160AB57d0829C48D93e3fc91"; // Replace with actual deployer address
  const deployedContract = m.deploy(fitnessMerged, [deployerAddress]);

  return { fitnessMerged, deployedContract };
});*/

// Replace with the actual address of the deployed contract
const CONTRACT_ADDRESS = '0x1B04132D7F2427cB160AB57d0829C48D93e3fc91'; 

module.exports = buildModule("FitnessMergedModule", (m) => {
  const fitnessMerged = m.contract("FitnessMerged", [CONTRACT_ADDRESS]);

  return { fitnessMerged };
});
