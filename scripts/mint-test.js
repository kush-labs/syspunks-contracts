const { ethers } = require('hardhat');

async function main() {
    // Get the contract to deploy
    const ContractFactory = await ethers.getContractFactory("SysPunksMarket");
    const punks = ContractFactory.attach("0xA48D667dEE58e80F8BA70B2D25DD92844B043fFE");
    const owner = "0x79A0e583C3BB4193BE1EcE116d15E5C4f92e59c2";

    for (var i = 0; i < 30; i++) {
        if (i <= 4) {
            const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.000000050")});
            console.log("Txid for 50000000000 gwei: ", txid.hash);
        } else if (i <= 8) {
            const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.000000100")});
            console.log("Txid for 100000000000 gwei: ", txid.hash);
        } else if (i <= 12) {
            const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.000000200")});
            console.log("Txid for 200000000000 gwei: ", txid.hash);
        } else if (i <= 16) {
            const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.000000300")});
            console.log("Txid for 300000000000 gwei: ", txid.hash); 
        }  else if (i <= 20) {
            const txid = await punks.mint({ value: hre.ethers.utils.parseEther("0.000000350")});
            console.log("Txid for 350000000000 gwei: ", txid.hash);
        }

        const index = (await punks.totalSupply()).toNumber();
        console.log("Index", index);
        console.log("\n");
    }
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });