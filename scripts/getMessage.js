// Import the ethers library
const { ethers } = require("ethers");

// Replace with your deployed contract address
const contractAddress = "0xE3ee1A6370edbe477a04998EF49a800E69bE0e6d";

// Import the ABI from the compiled artifacts
const fs = require('fs');
const contractABI = JSON.parse(fs.readFileSync('./artifacts/contracts/FirstContract.sol/HelloWorld.json')).abi;

// Connect to the Ethereum network using Alchemy
require('dotenv').config();
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

async function getCurrentMessage() {
  try {
    // Connect to the contract
    const helloWorldContract = new ethers.Contract(contractAddress, contractABI, provider);

    // Call the `message` function to get the current message
    const currentMessage = await helloWorldContract.message();
    console.log("Current Message:", currentMessage);
  } catch (error) {
    console.error("Error fetching message:", error);
  }
}

// Execute the function
getCurrentMessage();
