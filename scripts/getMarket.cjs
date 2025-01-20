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
const eventFactoryContract = new ethers.Contract(contractAddress, contractABI, wallet);

async function getMarketDetails(eventIndex, marketIndex) {
  try {
    console.log(`Fetching details for market index ${marketIndex} of event index ${eventIndex}...`);
    const marketDetails = await eventFactoryContract.getMarket(eventIndex, marketIndex);

    const [marketTitle, marketDescription] = marketDetails;

    console.log("Market Details:");
    console.log(`Title: ${marketTitle}`);
    console.log(`Description: ${marketDescription}`);
  } catch (error) {
    console.error("Error fetching market details:", error);
  }
  console.log(' ');
}

// Example: Retrieve details for market 0 of event 0
getMarketDetails(0, 0);
