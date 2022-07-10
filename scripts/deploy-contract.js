const hre = require("hardhat");

async function main() {


  // We get the contract to deploy
  const PunksMarket = await hre.ethers.getContractFactory("SysPunksMarket");
  const punks = await PunksMarket.deploy();

  await punks.deployed();

  console.log("SysPunksMarket to:", punks.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });