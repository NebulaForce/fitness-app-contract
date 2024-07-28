// scripts/deploy.js

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const DynamicNFTFactory = await ethers.getContractFactory("DynamicNFT");
    const dynamicNFT = await DynamicNFTFactory.deploy(deployer.address);
    console.log("DynamicNFT deployment transaction:", dynamicNFT.deployTransaction);

    await dynamicNFT.deployTransaction.wait(); // Check if deployTransaction exists
    console.log("DynamicNFT deployed to:", dynamicNFT.address);

    const FitnessTrackingFactory = await ethers.getContractFactory("FitnessTracking");
    const fitnessTracking = await FitnessTrackingFactory.deploy(dynamicNFT.address);
    console.log("FitnessTracking deployment transaction:", fitnessTracking.deployTransaction);

    await fitnessTracking.deployTransaction.wait(); // Check if deployTransaction exists
    console.log("FitnessTracking deployed to:", fitnessTracking.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
