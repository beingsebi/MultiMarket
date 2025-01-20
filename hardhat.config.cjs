require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("hardhat-contract-sizer");

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.28", 
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true, 
    },
  },
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {},
    sepolia: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  },
  // contractSizer: {
  //   runOnCompile: true, // Automatically check sizes when compiling
  //   disambiguatePaths: false, // Show full paths for disambiguation
  // },
}