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

async function placeMarketOrderByShares(
  eventIndex,
  marketIndex,
  betOutcome,  // 0 for "Yes", 1 for "No"
  orderSide,   // 0 for "Buy", 1 for "Sell"
  shares
) {
  try {
    console.log("Placing a market order by shares...");

    // Call the contract function (this does not send a transaction, it only simulates the call)
    const [filled, price, unfilled] = await contract.callStatic.placeMarketOrderByShares(
      eventIndex,
      marketIndex,
      betOutcome,
      orderSide,
      shares
    );

    console.log(`Filled: ${filled}`);
    console.log(`Price: ${price}`);
    console.log(`Unfilled: ${unfilled}`);
    
  } catch (error) {
    console.error("Error placing market order:", error);
  }
  console.log(' ');
}

// Example: Place a market order by shares
const betOutcome = process.env.OUTCOME;
const shares = process.env.SHARES;
const side = process.env.SIDE;

placeMarketOrderByShares(
  0,          // Event index
  0,          // Market index
  betOutcome, // Bet outcome: 0 for Yes, 1 for No
  side,       // Order type: 0 for Buy, 1 for Sell
  shares      // Shares: Amount of shares to trade
);
