import USDC_ABI from "./abis/USDC_ABI.json";
import MM_ABI from "./abis/MM_ABI.json";
import { ethers } from "ethers";
// import { CONTRACT_ADDRESS } from "./constants";
import { USD_CONTRACT_ADDRESS, MM_CONTRACT_ADDRESS } from "./constants";

// Module-level variables to store provider, signer, and contract
let provider;
let signer;
let usdcContract;
let MMContract;

const initialize = async () => {
  if (typeof window.ethereum !== "undefined") {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    signer = provider.getSigner();
    usdcContract = new ethers.Contract(USD_CONTRACT_ADDRESS, USDC_ABI, signer);
    MMContract = new ethers.Contract(MM_CONTRACT_ADDRESS, MM_ABI, signer);
  } else {
    console.error("Please install MetaMask!");
  }
};

// Initialize once when the module is loaded
initialize();

// Function to request single account
export const requestAccount = async () => {
  try {
    const accounts = await provider.send("eth_requestAccounts", []);
    return accounts[0]; // Return the first account
  } catch (error) {
    console.error("Error requesting account:", error.message);
    return null;
  }
};

// Function to get contract balance in ETH
export const getContractBalanceInETH = async () => {
  const balanceWei = await provider.getBalance(USD_CONTRACT_ADDRESS);
  const balanceEth = ethers.utils.formatEther(balanceWei); // Convert Wei to ETH string
  return balanceEth; // Convert ETH string to number
};

// Function to deposit funds to the contract
export const depositFund = async (depositValue) => {
  const ethValue = ethers.utils.parseEther(depositValue);
  const deposit = await usdcContract.deposit({ value: ethValue });
  await deposit.wait();
};

// Function to withdraw funds from the contract
export const withdrawFund = async () => {
  const withdrawTx = await usdcContract.withdraw();
  await withdrawTx.wait();
  console.log("Withdrawal successful!");
};
