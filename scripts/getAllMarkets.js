const { ethers } = require("ethers");
const fs = require("fs");
require('dotenv').config();

// Contract and ABI
const contractAddress = process.env.CONTRACT_ADDRESS;
const contractABI = JSON.parse(
  fs.readFileSync(process.env.CONTRACT_ABI_PATH)
).abi;

// Connect to the Ethereum network using Alchemy
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Initialize wallet with private key
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Create contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

async function getAllMarkets(marketIndex) {
  try {
    console.log(`Fetching  markets index `);
    const marketDetails = await contract.getAllMarkets(marketIndex);

    const [titles, descriptions] = marketDetails;

    for (let i = 0; i < titles.length; i++) {
      console.log(`market ${i}:`);
      console.log(`  Title: ${titles[i]}`);
      console.log(`  Description: ${descriptions[i]}`);
    }
  } catch (error) {
    console.error("Error fetching market details:", error);
  }
  console.log(' ');
}

const marketIndex=0;
// Example: Retrieve markets
getAllMarkets(marketIndex);
