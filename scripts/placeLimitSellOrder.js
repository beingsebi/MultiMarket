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
const ordersHelperContract = new ethers.Contract(contractAddress, contractABI, wallet);

async function placeSellOrderLimit(
  eventIndex,
  marketIndex,
  betOutcome,  // Use 0 for "Yes", 1 for "No"
  orderType,   // Use 1 for "Sell"
  price,
  shares
) {
  try {
    console.log("Placing a limit sell order...");

    // Call the placeOrder function
    const tx = await ordersHelperContract.placeOrder(
      eventIndex,
      marketIndex,
      betOutcome,
      orderType,
      price,
      shares
    );

    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait(); // Wait for the transaction to be mined

    console.log("Limit sell order placed successfully!");
    console.log(`Transaction Hash: ${receipt.transactionHash}`);
  } catch (error) {
    console.error("Error placing limit sell order:", error);
  }
}

// Example: Place a limit sell order
placeSellOrderLimit(
  0,          // Event index
  0,          // Market index
  1,          // Bet outcome: 1 for No
  1,          // Order type: 1 for Sell
  ethers.utils.parseUnits("0.2", 6), // Price: 0.2 (adjust decimals as needed)
  50          // Shares: 50
);
