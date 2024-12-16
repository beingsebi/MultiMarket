const { ethers } = require("ethers");
const fs = require("fs");
require('dotenv').config();

// Contract and ABI
const contractAddress = process.env.CONTRACT_ADDRESS;
const contractABI = JSON.parse(
  fs.readFileSync(process.env.CONTRACT_ABI_PATH)
).abi;

// Connect to Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Initialize wallet with private key
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Create contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

async function getPositions(eventIndex, userAddress) {
  try {
    console.log("Fetching positions...");

    // Call the getPositions function from the contract
    const [freeYesShares, reservedYesShares, freeNoShares, reservedNoShares ] = await contract.getPositions(eventIndex, userAddress);

    for (let i = 0; i < freeYesShares.length; i++) {
      console.log(`Market ${i}:`);
      console.log(`  Free Yes Shares: ${freeYesShares[i]}`);
      console.log(`  Reserved Yes Shares: ${reservedYesShares[i]}`);
      console.log(`  Free No Shares: ${freeNoShares[i]}`);
      console.log(`  Reserved No Shares: ${reservedNoShares[i]}`);
    }
  } catch (error) {
    console.error("Error fetching positions:", error);
  }
}

// Replace with the event index and user's address
const eventIndex = 0; // Example event index
const userAddress = process.env.PUBLIC_ADDRESS;

// Call the function to fetch positions
getPositions(eventIndex, userAddress);
