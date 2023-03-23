require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("hardhat-deploy");
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */

const RPC_URL = process.env.GOERLI_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN = process.env.ETHERSCAN_API
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP

module.exports = {
  solidity: "0.8.7",

  networks:{

    hardhat:{
      chainId: 31337,
      blockConfirmations:5
    },

    goerli:{
      url:RPC_URL,
      chainId: 5,
      accounts: [PRIVATE_KEY],
      blockConfirmations:5
    }
  },

  etherscan:{
    apiKey: ETHERSCAN
  },

  namedAccounts:{
    deployer:{
      default:0
    }
  },

  player:{
    default:1
  },
  
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    coinmarketcap: COINMARKETCAP_API_KEY,
  }

};
