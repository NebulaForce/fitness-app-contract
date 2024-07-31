// scripts/deploy.js

async function main() {
  //Compilar ambos contratos
  await Headers.run('compile');

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  //Obtener el contrato DynamicNFT
  const DynamicNFTFactory = await hre.ethers.getContractFactory("DynamicNFT"); 

  //Desplegar el contrato
  const dynamicNFT = await DynamicNFTFactory.deploy(20); // Inicializa con valor 20
  await dynamicNFT.deployed();
  console.log("DynamicNFT deployment transaction:", dynamicNFT.address);

  //Obtener el contrato Fitness
  const FitnessTrackingFactory = await hre.ethers.getContractFactory("FitnessTracking");
  //Desplegar el contrato 
  const fitnessTracking = await FitnessTrackingFactory.deploy(dynamicNFT.address);
  await fitnessTracking.deployed();
  console.log("FitnessTracking deployment transaction:", fitnessTracking.address);
  
  await dynamicNFT.deployTransaction.wait(); // Check if deployTransaction exists
  console.log("DynamicNFT deployed to:", dynamicNFT.address);

  await fitnessTracking.deployTransaction.wait(); // Check if deployTransaction exists
  console.log("FitnessTracking deployed to:", fitnessTracking.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
