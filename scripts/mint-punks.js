const { ethers } = require('hardhat');

async function main() {
    // Get the contract to deploy
    const ContractFactory = await ethers.getContractFactory("SysPunksMarket");
    const punks = ContractFactory.attach("0xA48D667dEE58e80F8BA70B2D25DD92844B043fFE");
    const owner = "0x79A0e583C3BB4193BE1EcE116d15E5C4f92e59c2";
    for (var i = 0; i < 45; i++) {
        const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.00000000000000050")});
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