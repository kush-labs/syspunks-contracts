const { ethers } = require('hardhat');

async function main() {
    // Get the contract to deploy
    const ContractFactory = await ethers.getContractFactory("SysPunksMarket");
    const punks = ContractFactory.attach("0x...");

    const txid = await punks.mint({ value: hre.ethers.utils.parseEther("350") });
    console.log("Txid: ", txid.hash);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });