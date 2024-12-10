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
const eventFactoryContract = new ethers.Contract(contractAddress, contractABI, wallet);

async function getEventDetails(eventIndex) {
  try {
    console.log(`Fetching details for event index ${eventIndex}...`);
    const eventDetails = await eventFactoryContract.getEvent(eventIndex);

    const [eventTitle, eventDescription, marketTitles, marketDescriptions] = eventDetails;

    console.log("Event Details:");
    console.log(`Title: ${eventTitle}`);
    console.log(`Description: ${eventDescription}`);
    console.log("Markets:");
    marketTitles.forEach((title, index) => {
      console.log(`  Market ${index + 1}:`);
      console.log(`    Title: ${title}`);
      console.log(`    Description: ${marketDescriptions[index]}`);
    });
  } catch (error) {
    console.error("Error fetching event details:", error);
  }
}

// Example: Retrieve details for event 0
getEventDetails(0);
