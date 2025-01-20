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

async function getAllEvents() {
  try {
    console.log(`Fetching  events index `);
    const eventDetails = await contract.getAllEvents();

    const [titles, descriptions] = eventDetails;

    for (let i = 0; i < titles.length; i++) {
      console.log(`Event ${i}:`);
      console.log(`  Title: ${titles[i]}`);
      console.log(`  Description: ${descriptions[i]}`);
    }
  } catch (error) {
    console.error("Error fetching event details:", error);
  }
  console.log(' ');
}

// Example: Retrieve events
getAllEvents();
