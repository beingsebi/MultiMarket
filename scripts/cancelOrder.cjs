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

async function cancelOrder(
  eventIndex,
    marketIndex,
    outcome,
    side,
    price,
    orderIndex
) {
  try {
    console.log("Canceling order...");
    
    // Call the createEvent function on the contract
    const tx = await contract.cancelOrder(
      eventIndex,
    marketIndex,
    outcome,
    side,
    price,
    orderIndex
    );
    
    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait(); // Wait for the transaction to be mined
    console.log("Order canceled successfully!");


  } catch (error) {
    console.error("Error creating event:", error);
  }
  console.log(' ');
}


// Parameters from environment variables
const eventIndex = 0;
const marketIndex = 0;
const outcome = process.env.OUTCOME;
const side = process.env.SIDE;
const price = process.env.PRICE;
const orderIndex = process.env.ORDER_INDEX;

// Call cancelOrder with parameters from environment variables
cancelOrder(eventIndex, marketIndex, outcome, side, price, orderIndex);
