const hre = require("hardhat");

async function main() {


  // We get the contract to deploy
  const PunksMarket = await hre.ethers.getContractFactory("MockToken");
  const punks = await PunksMarket.deploy("0x79A0e583C3BB4193BE1EcE116d15E5C4f92e59c2", "0x79A0e583C3BB4193BE1EcE116d15E5C4f92e59c2");

  await punks.deployed();

  console.log("MockToken to:", punks.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });