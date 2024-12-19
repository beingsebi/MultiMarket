import { ethers } from "ethers";
import { toast } from 'react-toastify';
import USDC_ABI from "./abis/USDC_ABI.json";
import MM_ABI from "./abis/MM_ABI.json";
import { MM_CONTRACT_ADDRESS, USD_CONTRACT_ADDRESS } from "./constants";

let cachedProvider = null;
let cachedSigner = null;
let cachedMMContract = null;
let cachedUSDCContract = null;

const BUY_ORDER = 0;
const SELL_ORDER = 1;

const getProviderAndSigner = async () => {
  if (cachedProvider && cachedSigner) {
    return { provider: cachedProvider, signer: cachedSigner };
  }

  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    cachedProvider = provider;
    cachedSigner = signer;
    return { provider, signer };
  } else {
    console.error("Please install MetaMask!");
    return null;
  }
};

const initializeContracts = async () => {
  if (cachedMMContract && cachedUSDCContract) {
    return {
      provider: cachedProvider,
      signer: cachedSigner,
      MMContract: cachedMMContract,
      usdcContract: cachedUSDCContract,
    };
  }

  const { provider, signer } = await getProviderAndSigner();
  if (!provider || !signer) return null;

  const MMContract = new ethers.Contract(MM_CONTRACT_ADDRESS, MM_ABI, signer);
  const usdcContract = new ethers.Contract(USD_CONTRACT_ADDRESS, USDC_ABI, signer);

  cachedMMContract = MMContract;
  cachedUSDCContract = usdcContract;

  return { provider, signer, MMContract, usdcContract };
};

export const requestAccount = async () => {
  try {
    const { provider } = await getProviderAndSigner();
    const accounts = await provider.send("eth_requestAccounts", []);
    return accounts[0]; // Return the first account
  } catch (error) {
    console.error("Error requesting account:", error.message);
    return null;
  }
};

export const getBalances = async (address) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return null;

    const freeBalance = await MMContract.freeBalances(address);
    const reservedBalance = await MMContract.reservedBalances(address);
    const totalBalance = ethers.BigNumber.from(freeBalance).add(ethers.BigNumber.from(reservedBalance));

    return {
      freeBalance: ethers.utils.formatUnits(freeBalance, 6),
      reservedBalance: ethers.utils.formatUnits(reservedBalance, 6),
      totalBalance: ethers.utils.formatUnits(totalBalance, 6),
    };
  } catch (error) {
    console.error("Error fetching balance:", error);
    return null;
  }
};

export const depositUSDC = async (amount) => {
  console.log("Deposit amount: ", amount);
  const parsedAmount = ethers.utils.parseUnits(amount.toString(), 6);
  try {
    const { MMContract, usdcContract, signer } = await initializeContracts();
    if (!MMContract || !usdcContract) {
      console.error("Contracts not initialized!");
      return;
    }

    const walletAddress = await signer.getAddress();
    const allowance = await usdcContract.allowance(walletAddress, MM_CONTRACT_ADDRESS);

    if (ethers.BigNumber.from(allowance) < ethers.BigNumber.from(parsedAmount)) {
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
    return error;
  }
};

export const withdrawUSDC = async (amount) => {
  console.log("Withdraw amount: ", amount);
  const parsedAmount = ethers.utils.parseUnits(amount.toString(), 6);
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) {
      console.error("Contract not initialized!");
      return;
    }

    console.log(`Withdrawing ${parsedAmount} USDC from the MultiMarket contract...`);
    const withdrawTx = await MMContract.withdraw(parsedAmount);
    await withdrawTx.wait();
    console.log("Withdrawal successful!");
  } catch (error) {
    console.error("Error during withdrawal:", error);
    return error;
  }
};

export const getAllEvents = async () => {
  try {
    const { MMContract } = await initializeContracts();
    console.log(`Fetching events index`);
    const eventsDetails = await MMContract.getAllEvents();

    const [titles, descriptions] = eventsDetails;
    console.log('eventsDetails: ', eventsDetails);

    const events = titles.map((title, index) => ({
      title,
      description: descriptions[index],
    }));

    return events;
  } catch (error) {
    console.error("Error fetching event details:", error);
    return [];
  }
};

export const getEvent = async (eventIndex) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return null;
    console.log(`Fetching details for event index ${eventIndex}...`);

    const eventIndexBigNumber = ethers.BigNumber.from(eventIndex);
    const eventDetails = await MMContract.getEvent(eventIndexBigNumber);
    console.log("Event Details:", eventDetails);

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

    return {
      eventTitle,
      eventDescription,
      marketTitles,
      marketDescriptions
    };
  } catch (error) {
    console.error("Error fetching event details:", error);
    return null;
  }
};

const placeLimitOrder = async (eventIndex, marketIndex, betOutcome, price, shares, orderType) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return;

    console.log(`Placing a limit ${orderType === BUY_ORDER ? 'buy' : 'sell'} order...`);

    const tx = await MMContract.placeLimitOrder(
      eventIndex,
      marketIndex,
      betOutcome,
      orderType,
      ethers.utils.parseUnits(price.toString(), 6),
      ethers.BigNumber.from(shares)
    );

    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait();

    console.log(`Limit ${orderType === BUY_ORDER ? 'buy' : 'sell'} order placed successfully!`);
    console.log(`Transaction Hash: ${receipt.transactionHash}`);
  } catch (error) {
    console.error(`Error placing limit ${orderType === BUY_ORDER ? 'buy' : 'sell'} order:`, error);
    toast.error(`Error placing limit ${orderType === BUY_ORDER ? 'buy' : 'sell'} order: ${error.reason}`);
    return error;
  }
};

export const placeLimitBuyOrder = async (eventIndex, marketIndex, betOutcome, price, shares) => {
  return placeLimitOrder(eventIndex, marketIndex, betOutcome, price, shares, BUY_ORDER);
};

export const placeLimitSellOrder = async (eventIndex, marketIndex, betOutcome, price, shares) => {
  return placeLimitOrder(eventIndex, marketIndex, betOutcome, price, shares, SELL_ORDER);
};

export const placeMarketOrder = async (eventIndex, marketIndex, betOutcome, orderSide, shares) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return;

    console.log("Placing a market order...");

    const tx = await MMContract.placeMarketOrderByShares(
      eventIndex,
      marketIndex,
      betOutcome,
      orderSide,
      ethers.BigNumber.from(shares)
    );

    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait();

    console.log("Market order placed successfully!");
    console.log(`Transaction Hash: ${receipt.transactionHash}`);
  } catch (error) {
    console.error("Error placing market order:", error);
  }
};

export const getPositions = async (eventIndex, userAddress) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return null;

    console.log("Fetching positions...");

    const [freeYesShares, reservedYesShares, freeNoShares, reservedNoShares] = await MMContract.getPositions(eventIndex, userAddress);

    const positions = freeYesShares.map((_, index) => ({
      marketIndex: index,
      freeYesShares: ethers.utils.formatUnits(freeYesShares[index], 0),
      reservedYesShares: ethers.utils.formatUnits(reservedYesShares[index], 0),
      freeNoShares: ethers.utils.formatUnits(freeNoShares[index], 0),
      reservedNoShares: ethers.utils.formatUnits(reservedNoShares[index], 0),
    }));

    return positions;
  } catch (error) {
    console.error("Error fetching positions:", error);
    return [];
  }
};