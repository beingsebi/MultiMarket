import { BrowserProvider, Contract, formatUnits, parseEther, formatEther, JsonRpcProvider, parseUnits } from "ethers";
import { toBigInt } from "ethers/utils";
import USDC_ABI from "./USDC_ABI.json";
import MM_ABI from "./MM_ABI.json";
import { MM_CONTRACT_ADDRESS, USD_CONTRACT_ADDRESS } from "./constants";


const getProviderAndSigner = async () => {
  if (typeof window.ethereum !== "undefined") {
    const provider = new BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    return { provider, signer };
  } else {
    console.error("Please install MetaMask!");
    return null;
  }
}

// Function to initialize the provider, signer, and contracts
const initializeContracts = async () => {
  if (typeof window.ethereum !== "undefined") {
    const { provider, signer } = await getProviderAndSigner();
    console.log("Provider and signer initialized!");
    console.log("Provider: ", provider);
    console.log("Signer: ", signer);   
    const MMContract = new Contract(MM_CONTRACT_ADDRESS, MM_ABI, signer);
    console.log("MMContract: ", MMContract);
    const usdcContract = new Contract(USD_CONTRACT_ADDRESS, USDC_ABI, signer);
    console.log("usdcContract: ", usdcContract);
    return { provider, signer, MMContract, usdcContract };
  } else {
    console.error("Please install MetaMask!");
    return null;
  }
};

// Function to get balances
export const getBalances = async (address) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return null;

    const freeBalance = await MMContract.freeBalances(address);
    const reservedBalance = await MMContract.reservedBalances(address);
    const totalBalance = toBigInt(freeBalance) + toBigInt(reservedBalance)

    return {
      freeBalance: formatUnits(freeBalance, 6),
      reservedBalance: formatUnits(reservedBalance, 6),
      totalBalance: formatUnits(totalBalance, 6),
    };
  } catch (error) {
    console.error("Error fetching balance:", error);
    return null;
  }
};

// Function to deposit USDC
export const depositUSDC = async (amount) => {
  console.log("Deposit amount: ", amount);
  const parsedAmount = parseUnits(amount, 6);
  try {
    const { MMContract, usdcContract, signer } = await initializeContracts();
    if (!MMContract || !usdcContract) {
      console.error("Contracts not initialized!");
      return;
    }

    const walletAddress = await signer.getAddress();
    const allowance = await usdcContract.allowance(walletAddress, MM_CONTRACT_ADDRESS);

    if (toBigInt(allowance) < toBigInt(parsedAmount)) {
      console.log(`Approving contract to spend ${parsedAmount} USDC...`);
      const approveTx = await usdcContract.approve(MM_CONTRACT_ADDRESS, parsedAmount);
      await approveTx.wait();
      console.log("Approval transaction confirmed.");
    }

    console.log(`Depositing ${parsedAmount} USDC to the MultiMarket contract...`);
    const depositTx = await MMContract.deposit(parsedAmount);
    await depositTx.wait();
    console.log("Deposit successful!");
  } catch (error) {
    console.error("Error during deposit:", error);
  }
};