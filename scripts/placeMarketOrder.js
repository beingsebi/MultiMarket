const { ethers } = require("ethers");
const fs = require("fs");
require('dotenv').config();

// Contract and ABI
const contractAddress = process.env.CONTRACT_ADDRESS;
const contractABI = JSON.parse(fs.readFileSync(process.env.CONTRACT_ABI_PATH)).abi;

// Connect to the Ethereum network using Alchemy
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Initialize wallet with private key
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Create contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

async function placeMarketOrderByShares(eventIndex, marketIndex, betOutcome, orderSide, shares) {
  try {
    console.log("Placing a market order by shares...");

    // Send the transaction to the blockchain
    const tx = await contract.placeMarketOrderByShares(
      eventIndex,
      marketIndex,
      betOutcome,
      orderSide,
      shares
    );

    // Wait for the transaction to be mined
    console.log(`Transaction hash: ${tx.hash}`);
    const receipt = await tx.wait();
    console.log("Transaction confirmed!");

    // Retrieve the specific event
    const event = receipt.events?.find(event => event.event === "MarketOrderPlaced");
    if (event) {
      console.log("Event found:", event);

      // Accessing the arguments by name
      const { 
        user, 
        eventIndex, 
        marketIndex, 
        betOutcome, 
        orderSide, 
        filledShares, 
        totalCostOfFilledShares, 
        unfilledShares 
      } = event.args;

      // Logging values
      console.log(`User: ${user}`);
      console.log(`Event Index: ${eventIndex.toString()}`);
      console.log(`Market Index: ${marketIndex.toString()}`);
      console.log(`Bet Outcome: ${betOutcome}`);
      console.log(`Order Side: ${orderSide}`);
      console.log(`Filled Shares: ${filledShares.toString()}`);
      console.log(`Total Cost of Filled Shares: ${totalCostOfFilledShares.toString()}`);
      console.log(`Unfilled Shares: ${unfilledShares.toString()}`);
    } else {
      console.error("Event not found in transaction receipt.");
    }
  } catch (error) {
    console.error("Error placing market order:", error);
  }
}

// Example: Place a market order by shares
const betOutcome = parseInt(process.env.OUTCOME);
const shares = ethers.BigNumber.from(process.env.SHARES);
const side = parseInt(process.env.SIDE);

placeMarketOrderByShares(
  0,          // Event index
  0,          // Market index
  betOutcome, // Bet outcome: 0 for Yes, 1 for No
  side,       // Order type: 0 for Buy, 1 for Sell
  shares      // Shares: Amount of shares to trade
);
