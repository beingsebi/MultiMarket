const { ethers } = require("ethers");
const fs = require("fs");

require('dotenv').config();

// Contract and ABI
const eventFactoryAddress = process.env.EVENT_FACTORY_ADDRESS;
const eventFactoryABI = JSON.parse(
  fs.readFileSync(process.env.EVENT_FACTORY_ABI_PATH)
).abi;

// Connect to the Ethereum network using Alchemy
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Initialize wallet with private key
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Create contract instance for Event Factory
const eventFactoryContract = new ethers.Contract(eventFactoryAddress, eventFactoryABI, wallet);

async function transferOwnership() {
  try {
    // Step 1: Call the transferOwnership function
    const newOwner = process.env.CONTRACT_ADDRESS;
    console.log(`Transferring ownership of the EventFactory contract to ${newOwner}...`);

    const transferTx = await eventFactoryContract.transferOwnership(newOwner);
    await transferTx.wait();

    console.log("Ownership transfer successful!");
  } catch (error) {
    console.error("Error during ownership transfer:", error);
  }
  console.log(' ');
}

// Execute the transfer ownership function
transferOwnership();
