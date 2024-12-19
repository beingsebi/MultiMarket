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

async function resolveMarket(eventIndex, marketIndex, winningOutcome) {
  try {
    console.log("Resolving market...");

    // Call the resolveMarket function
    const tx = await contract.resolveMarket(eventIndex, marketIndex, winningOutcome);

    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait(); // Wait for the transaction to be mined

    console.log("Market resolved successfully!");
    console.log(`Transaction Hash: ${receipt.transactionHash}`);
  } catch (error) {
    console.error("Error resolving market:", error);
  }
}


  // Hardcoded indices
  const eventIndex = 0;
  const marketIndex = 0;

  // Winning outcome from environment variable
  const winningOutcome = process.env.OUTCOME

  // Call resolveMarket with hardcoded indices and environment outcome
  resolveMarket(eventIndex, marketIndex, winningOutcome);
