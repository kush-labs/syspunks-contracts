/* global BigInt */
const { BigNumber } = require("ethers");
const hre = require("hardhat");

async function main() {

  const initSupply = new BigNumber.from("100000000000000000000000");

  // We get the contract to deploy
  const PunksMarket = await hre.ethers.getContractFactory("ERC20Mock");
  const punks = await PunksMarket.deploy("Syspunks Test Token", "PUNKSYS", "0x...", initSupply);

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