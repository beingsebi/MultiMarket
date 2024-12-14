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
const marketContract = new ethers.Contract(contractAddress, contractABI, wallet);

// Enum values for BetOutcome (adjust based on the contract's definition)
const BetOutcome = {
  Yes: 0,
  No: 1,
};

async function getUserInfo(userAddress) {
  try {
    console.log("Fetching user information...");

    // Free shares for Yes and No
    const freeSharesYes = await marketContract.freeShares(BetOutcome.Yes, userAddress);
    const freeSharesNo = await marketContract.freeShares(BetOutcome.No, userAddress);

    // Reserved shares for Yes and No
    const reservedSharesYes = await marketContract.reservedShares(BetOutcome.Yes, userAddress);
    const reservedSharesNo = await marketContract.reservedShares(BetOutcome.No, userAddress);

    // Active orders count
    const activeOrders = await marketContract.userActiveOrdersCount(userAddress);

    // Log results
    console.log(`User Address: ${userAddress}`);
    console.log(`Free Shares (Yes): ${freeSharesYes.toString()}`);
    console.log(`Free Shares (No): ${freeSharesNo.toString()}`);
    console.log(`Reserved Shares (Yes): ${reservedSharesYes.toString()}`);
    console.log(`Reserved Shares (No): ${reservedSharesNo.toString()}`);
    console.log(`Active Orders: ${activeOrders.toString()}`);
  } catch (error) {
    console.error("Error fetching user information:", error);
  }
}

// Replace with the user's address
const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";

// Call the function to fetch and print user information
getUserInfo(userAddress);
