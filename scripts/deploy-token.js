/* global BigInt */
const { BigNumber } = require("ethers");
const hre = require("hardhat");

async function main() {

  const initSupply = new BigNumber.from(10**10);

  // We get the contract to deploy
  const PunksMarket = await hre.ethers.getContractFactory("ERC20Mock");
  const punks = await PunksMarket.deploy("Syspunks Test Token", "PUNKSYS", "0x79A0e583C3BB4193BE1EcE116d15E5C4f92e59c2", initSupply);

  await punks.deployed();

  console.log("ERC20Mock to:", punks.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });