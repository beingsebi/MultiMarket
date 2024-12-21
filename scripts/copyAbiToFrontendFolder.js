const fs = require('fs');
const path = require('path');
require('dotenv').config();

const contractABIPath = "./artifacts/contracts/03_OrderPlacer.sol/OrderPlacer.json";
const contractOutputFilePath = path.resolve(__dirname, '../frontend/src/utils/abis/MM_ABI.json');

const usdcContractABIPath = "./artifacts/contracts/external/USDC.sol/USDC.json";
const usdcOutputFilePath = path.resolve(__dirname, '../frontend/src/utils/abis/USDC_ABI.json');

try {
  const contractABI = JSON.parse(fs.readFileSync(contractABIPath)).abi;
  fs.writeFileSync(contractOutputFilePath, JSON.stringify(contractABI, null, 2));

  const usdcABI = JSON.parse(fs.readFileSync(usdcContractABIPath)).abi;
  fs.writeFileSync(usdcOutputFilePath, JSON.stringify(usdcABI, null, 2));

  console.log(`ABI successfully written to ${contractOutputFilePath} and ${usdcOutputFilePath}`);
} catch (error) {
  console.error('Error reading or writing ABI:', error);
}