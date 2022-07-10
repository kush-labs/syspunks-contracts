const { ethers } = require('hardhat');

async function main() {
    // Get the contract to deploy
    const ContractFactory = await ethers.getContractFactory("SysPunksMarket");
    const punks = ContractFactory.attach("0x85D39E43E0E9c5a1311241ff1357E54f588eb11F");
    const owner = "0x79A0e583C3BB4193BE1EcE116d15E5C4f92e59c2";
    for (var i = 0; i < 45; i++) {
        const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.0000000000000001")});
        console.log("Txid for: ", txid.hash);
        const index = (await punks.totalSupply()).toNumber();
        console.log(index)
    }
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });