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

const MMContract = new ethers.Contract(contractAddress, contractABI, wallet);

// Create contract instance for USDC
const usdcContract = new ethers.Contract(process.env.USDC_ADDRESS, [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function allowance(address owner, address spender) external view returns (uint256)"
], wallet);


async function deposit(amount) {
  try {
    // Step 1: Approve the contract to spend USDC on behalf of the user
    const allowance = await usdcContract.allowance(wallet.address, contractAddress);
    if (allowance < amount) {
      console.log(`Approving contract to spend ${amount} USDC...`);
      const approveTx = await usdcContract.approve(contractAddress, amount);
      await approveTx.wait();
      console.log("Approval transaction confirmed.");
    }

    // Step 2: Call the deposit function of the MultiMarket contract
    console.log(`Depositing ${amount} USDC to the MultiMarket contract...`);
    const depositTx = await MMContract.deposit(amount);
    await depositTx.wait();
    console.log("Deposit successful!");
  } catch (error) {
    console.error("Error during deposit:", error);
  }
  console.log(' ');
}

// Example: deposit 1000 USDC
deposit(ethers.utils.parseUnits("1000", 6)); // USDC typically has 6 decimal places
