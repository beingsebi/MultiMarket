const { ethers } = require("ethers");
const fs = require("fs");

require('dotenv').config();

// Contract and ABI
const contractAddress = process.env.CONTRACT_ADDRESS;
const contractABI = JSON.parse(
  fs.readFileSync('./artifacts/contracts/02_EventFactory.sol/EventFactory.json')
).abi;

// Connect to the Ethereum network using Alchemy
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Create contract instance for MultiMarket
const MMContract = new ethers.Contract(contractAddress, contractABI, provider);

async function getBalance(address) {
  try {
    const balance = await MMContract.balances(address);
    console.log(`Balance of address ${address} in MultiMarket contract: ${ethers.utils.formatUnits(balance, 6)} USDC`);
  } catch (error) {
    console.error("Error fetching balance:", error);
  }
}

// Example: Get the balance of a specific address
const addressToCheck = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  

getBalance(addressToCheck);
