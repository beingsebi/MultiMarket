import { BrowserProvider, Contract, formatUnits, formatEther } from "ethers";
import USDC_ABI from "./USDC_ABI.json";
import MM_ABI from "./MM_ABI.json";
import { MM_CONTRACT_ADDRESS, USD_CONTRACT_ADDRESS } from "./constants";


// Function to initialize the provider, signer, and contracts
const initializeContracts = async () => {
  if (typeof window.ethereum !== "undefined") {
    const provider = new BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const MMContract = new Contract(MM_CONTRACT_ADDRESS, MM_ABI, signer);
    const usdcContract = new Contract(USD_CONTRACT_ADDRESS, USDC_ABI, signer);
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
    const reservedBalance =0// await MMContract.reservedBalances(address);
    const totalBalance = freeBalance.add(reservedBalance);

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
  try {
    const { MMContract, usdcContract, signer } = await initializeContracts();
    if (!MMContract || !usdcContract) {
        console.error("Contracts not initialized!");
        return;
    }
    const walletAddress = await signer.getAddress();
    const allowance = await usdcContract.allowance(walletAddress, MM_CONTRACT_ADDRESS);

    if (allowance.lt(amount)) {
      console.log(`Approving contract to spend ${amount} USDC...`);
      const approveTx = await usdcContract.approve(MM_CONTRACT_ADDRESS, amount);
      await approveTx.wait();
      console.log("Approval transaction confirmed.");
    }

    // console.log(`Depositing ${amount} USDC to the MultiMarket contract...`);
    // const depositTx = await MMContract.deposit(amount);
    // await depositTx.wait();
    console.log("Deposit successful!");
  } catch (error) {
    console.error("Error during deposit:", error);
  }
};