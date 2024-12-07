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

// Use your wallet private key to create a signer
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

async function updateMessage(newMessage) {
  try {
    // Connect to the contract
    const helloWorldContract = new ethers.Contract(contractAddress, contractABI, wallet);

    // Call the `update` function to change the message
    const tx = await helloWorldContract.update(newMessage);

    // Wait for the transaction to be mined
    console.log("Transaction Sent. Waiting for confirmation...");
    const receipt = await tx.wait();
    console.log("Transaction Confirmed!", receipt);
    
    // Optionally, you can fetch the updated message
    const currentMessage = await helloWorldContract.message();
    console.log("Updated Message:", currentMessage);
  } catch (error) {
    console.error("Error updating message:", error);
  }
}

// Execute the function with a new message
const newMessage = "New message on the blockchain!";
updateMessage(newMessage);
