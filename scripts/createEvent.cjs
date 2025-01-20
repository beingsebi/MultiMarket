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

async function insertEvent(
  eventTitle,
  eventDescription
) {
  try {
    console.log("Creating a new event...");
    
    // Call the createEvent function on the contract
    const tx = await contract.createEvent(
      eventTitle,
      eventDescription
    );
    
    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait(); // Wait for the transaction to be mined
    console.log("Event created successfully!");

    // Log the transaction hash and event creation details
    console.log("Event Details:");
    console.log(`  Title: ${eventTitle}`);
    console.log(`  Description: ${eventDescription}`);
  } catch (error) {
    console.error("Error creating event:", error);
  }
  console.log(' ');
}

// Example: Create an event
insertEvent(
  "Sample Event",
  "This is a test event for demonstration purposes"
);
