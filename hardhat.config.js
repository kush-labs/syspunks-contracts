require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');
require('hardhat-contract-sizer');

const dotenv = require('dotenv');
dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.1",
  // solidity: "0.5.16",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000
    }
  },
  networks: {
    mumbai: {
      url:
        process.env.MUMBAI_ENDPOINT,
      accounts: [process.env.DEPLOY_ACCOUNT_PRIVATE_KEY]
    },
    polygon: {
      url: process.env.POLYGON_ENDPOINT,
      accounts: [process.env.DEPLOY_ACCOUNT_PRIVATE_KEY],
      timeout: 2000000,
      gasPrice: 100000000000,
      gasMultiplier: 2
    },
    tanenbaum: {
      url: process.env.TANENBAUM_ENDPOINT,
      gasPrice: "auto",
      hardfork: "london",
      chainId: 5700,
      accounts: [process.env.DEPLOY_ACCOUNT_PRIVATE_KEY]
    },
    nevm: {
      url: process.env.NEVM_ENDPOINT,
      gasPrice: "auto",
      hardfork: "london",
      chainId: 57,
      accounts: [process.env.DEPLOY_ACCOUNT_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_KEY,
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    only: [],
  }
};
