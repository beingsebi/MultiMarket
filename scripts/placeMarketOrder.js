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

async function placeMarketOrderByShares(
  eventIndex,
  marketIndex,
  betOutcome,  // Use 0 for "Yes", 1 for "No"
  orderSide,   // Use 0 for "Buy", 1 for "Sell"
  shares
) {
  try {
    console.log("Placing a market order by shares...");

    // Call the placeMarketOrderByShares function
    const tx = await ordersHelperContract.placeMarketOrderByShares(
      eventIndex,
      marketIndex,
      betOutcome,
      orderSide,
      shares
    );

    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait(); // Wait for the transaction to be mined

    console.log("Market order placed successfully!");
    console.log(`Transaction Hash: ${receipt.transactionHash}`);
  } catch (error) {
    console.error("Error placing market order:", error);
  }
  console.log(' ');
}

// Example: Place a market order by shares
const betOutcome = process.env.OUTCOME;
const shares = process.env.SHARES;
const side= process.env.SIDE;

placeMarketOrderByShares(
  0,          // Event index
  0,          // Market index
  betOutcome,          // Bet outcome: 0 for Yes, 1 for No
  side,          // Order type: 0 for Buy, 1 for Sell
  shares         // Shares: Amount of shares to trade
);


