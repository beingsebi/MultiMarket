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

// Create contract instance for MultiMarket
const MMContract = new ethers.Contract(contractAddress, contractABI, provider);

async function getBalance(address) {
  try {
    const freeBalance = await MMContract.freeBalances(address);
    const resBalance=  await MMContract.reservedBalances(address);
    const balance = freeBalance.add(resBalance); //NOT + operator ; it is not good!!!

    console.log(`free Balance of address ${address} in MultiMarket contract: ${ethers.utils.formatUnits(freeBalance, 6)} USDC`);
    console.log(`reserved Balance of address ${address} in MultiMarket contract: ${ethers.utils.formatUnits(resBalance, 6)} USDC`);
    console.log(`total Balance of address ${address} in MultiMarket contract: ${ethers.utils.formatUnits(balance, 6)} USDC`);
  } catch (error) {
    console.error("Error fetching balance:", error);
  }
  console.log(' ');

}

// Example: Get the balance of a specific address
const addressToCheck = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  

getBalance(addressToCheck);
