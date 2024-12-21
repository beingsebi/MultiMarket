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

async function getActiveOrders(eventIndex, marketIndex, betOutcome, orderSide, user) {
  try {
    console.log("Fetching active orders...");

    // Call the getActiveOrders function
    const activeOrders = await contract.getActiveOrders(eventIndex, marketIndex, betOutcome, orderSide, user);

    console.log("Active orders retrieved successfully!");
    // console.log(activeOrders); // Print the retrieved orders
    return activeOrders;
 
  } catch (error) {
    console.error("Error fetching active orders:", error);
    throw error;
  }
}

// Hardcoded indices
const eventIndex = 0;
const marketIndex = 0;

// BetOutcome and OrderSide from environment variables
const betOutcome = process.env.OUTCOME; // Directly from environment
const orderSide = process.env.SIDE; // Directly from environment

// Call getActiveOrders with hardcoded indices and environment variables
const user = process.env.PUBLIC_ADDRESS;

getActiveOrders(eventIndex, marketIndex, betOutcome, orderSide, user)
  .then((orders) => {
     orders.forEach((order, index) => {
    console.log(`Order ${index + 1}:`);
    console.log(`  User: ${order.user}`);
    console.log(`  Initial Shares: ${order.initialShares}`);
    console.log(`  Remaining Shares: ${order.remainingShares}`);
    console.log(`  Timestamp: ${new Date(order.timestamp * 1000).toLocaleString()}`);
    console.log(`  Is Active: ${order.isActive}`);
    console.log(`  Current Total Price: ${order.currentTotalPrice}`);
  });
  })
  .catch((error) => {
    console.error("Error:", error);
  });
