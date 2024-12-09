const { ethers } = require("ethers");
const fs = require("fs");

// Contract and ABI
const contractAddress = process.env.CONTRACT_ADDRESS;
const contractABI = JSON.parse(
  fs.readFileSync('./artifacts/contracts/02_EventFactory.sol/EventFactory.json')
).abi;

// Connect to the Ethereum network using Alchemy
require('dotenv').config();
const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);

// Initialize wallet with private key
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Create contract instance for MultiMarket
const MMContract = new ethers.Contract(contractAddress, contractABI, wallet);

async function withdraw(amount) {
  try {
    console.log(`Withdrawing ${ethers.utils.formatUnits(amount, 6)} USDC from the MultiMarket contract...`);
    const withdrawTx = await MMContract.withdraw(amount);
    await withdrawTx.wait();
    console.log("Withdrawal successful!");
  } catch (error) {
    console.error("Error during withdrawal:", error);
  }
}

// Example: withdraw 100 USDC
withdraw(ethers.utils.parseUnits("100", 6)); // USDC typically has 6 decimal places
