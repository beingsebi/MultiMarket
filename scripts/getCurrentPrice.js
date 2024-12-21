const { ethers } = require("ethers");
const fs = require("fs");
require("dotenv").config();

// Contract and ABI
const contractAddress = process.env.CONTRACT_ADDRESS;
const contractABI = JSON.parse(
  fs.readFileSync(process.env.CONTRACT_ABI_PATH)
).abi;

// Connect to Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Create contract instance (read-only)
const contract = new ethers.Contract(contractAddress, contractABI, provider);

async function getCurrentPrice(eventIndex, marketIndex, betOutcome) {
  try {
    console.log("Fetching current price...");

    // Call the getCurrentPrice function
    const [priceNumerator, priceDenominator] = await contract.getCurrentPrice(
      eventIndex,
      marketIndex,
      betOutcome
    );

    console.log("Current Price fetched successfully!");
    console.log(`Price: ${priceNumerator.toString()} / ${priceDenominator.toString()}`);
  } catch (error) {
    console.error("Error fetching current price:", error);
  }
}

// Hardcoded parameters
const eventIndex = 0;
const marketIndex = 0;

// BetOutcome value
const betOutcome = process.env.OUTCOME;

// Call getCurrentPrice with hardcoded parameters
getCurrentPrice(eventIndex, marketIndex, betOutcome);
