import { ethers } from "ethers";
import { toast } from 'react-toastify';
import USDC_ABI from "./abis/USDC_ABI.json";
import MM_ABI from "./abis/MM_ABI.json";
import { MM_CONTRACT_ADDRESS, USD_CONTRACT_ADDRESS } from "./constants";

let cachedProvider = null;
let cachedSigner = null;
let cachedMMContract = null;
let cachedUSDCContract = null;
let isRequestingAccounts = false;
let isRequestingAccount = false;
let cachedAccount = null;

const BUY_ORDER = 0;
const SELL_ORDER = 1;

const getProviderAndSigner = async () => {
  if (cachedProvider && cachedSigner) {
    return { provider: cachedProvider, signer: cachedSigner };
  }

  if (typeof window.ethereum !== "undefined") {
    if (isRequestingAccounts) {
      console.warn("Already requesting accounts. Please wait.");
      return null;
    }

    isRequestingAccounts = true;
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      cachedProvider = provider;
      cachedSigner = signer;
      return { provider, signer };
    } catch (error) {
      if (error.code === -32002) {
        console.warn("Already processing eth_requestAccounts. Please wait.");
      } else {
        console.error("Error requesting accounts:", error);
      }
      return null;
    } finally {
      isRequestingAccounts = false;
    }
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
  if (isRequestingAccount) {
    return cachedAccount; // Return cached account if already requesting
  }

  isRequestingAccount = true;

  try {
    const { provider } = await getProviderAndSigner();
    const accounts = await provider.send("eth_requestAccounts", []);
    cachedAccount = accounts[0]; // Cache the first account
    return cachedAccount;
  } catch (error) {
    console.error("Error requesting account:", error); // Log the full error object for debugging
    toast.error("Error requesting account. Please make sure to connect your wallet."); // Display a user-friendly error message
    return null;
  } finally {
    isRequestingAccount = false;
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
    toast.error(`Error fetching balance: ${error.reason}`);
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
      const approveTx = await usdcContract.approve(MM_CONTRACT_ADDRESS, parsedAmount, { gasLimit: 100000 });
      await approveTx.wait();
      console.log("Approval transaction confirmed.");
    }

    console.log(`Depositing ${parsedAmount} USDC to the MultiMarket contract...`);
    const depositTx = await MMContract.deposit(parsedAmount, { gasLimit: 100000 });
    await depositTx.wait();
    console.log("Deposit successful!");
      toast.success("Deposit successful!");
  } catch (error) {
    console.error("Error during deposit:", error);
    toast.error(`Error during deposit: ${error.reason}`);
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
    const withdrawTx = await MMContract.withdraw(parsedAmount, { gasLimit: 100000 });
    await withdrawTx.wait();
    console.log("Withdrawal successful!");
    toast.success("Withdrawal successful!");
  } catch (error) {
    console.error("Error during withdrawal:", error);
    toast.error(`Error during withdrawal: ${error.reason}`);
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
    toast.error(`Error fetching event details: ${error.reason}`);
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

    const [eventTitle, eventDescription, marketTitles, marketDescriptions, marketResolved] = eventDetails;

    console.log("Event Details:");
    console.log(`Title: ${eventTitle}`);
    console.log(`Description: ${eventDescription}`);
    console.log("Markets:");
    marketTitles.forEach((title, index) => {
      console.log(`  Market ${index + 1}:`);
      console.log(`    Title: ${title}`);
      console.log(`    Description: ${marketDescriptions[index]}`);
      console.log(`    Resolved: ${marketResolved[index]}`);
    });

    return {
      eventTitle,
      eventDescription,
      marketTitles,
      marketDescriptions,
      marketResolved
    };
  } catch (error) {
    console.error("Error fetching event details:", error);
    toast.error(`Error fetching event details: ${error.reason}`);
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
    await tx.wait();

    console.log(`Limit ${orderType === BUY_ORDER ? 'buy' : 'sell'} order placed successfully!`);
    toast.success(`Limit ${orderType === BUY_ORDER ? 'buy' : 'sell'} order placed successfully!`);
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
    await tx.wait();

    console.log("Market order placed successfully!");
    toast.success("Market order placed successfully!");
  } catch (error) {
    console.error("Error placing market order:", error);
    toast.error(`Error placing market order: ${error.reason}`);
  }
};

export const getPositions = async (eventIndex, userAddress) => {
  if (userAddress === null) {
    return [];
  }
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
    toast.error(`Error fetching positions: ${error.reason}`);
    return [];
  }
};

export const getActiveOrders = async (eventIndex, marketIndex, betOutcome, orderSide, userAddress) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return null;

    console.log("Fetching active orders...");
    console.log(eventIndex, marketIndex, betOutcome, orderSide, userAddress);
    const activeOrders = await MMContract.getActiveOrders(
      eventIndex,
      marketIndex,
      betOutcome,
      orderSide,
      userAddress
    );

    return activeOrders.map(order => ({
      initialShares: order.initialShares.toString(),
      remainingShares: order.remainingShares.toString(),
      timestamp: new Date(order.timestamp * 1000).toLocaleString(),
      totalCostOfFilledShares: ethers.utils.formatUnits(order.totalCostOfFilledShares, 6),
      price: ethers.utils.formatUnits(order.price, 6),
      indexInOrderBook: order.index.toString(),
    }));
  } catch (error) {
    console.error("Error fetching active orders:", error);
    toast.error(`Error fetching active orders: ${error.reason}`);
    return [];
  }
};

export const getCurrentPrice = async (eventIndex, marketIndex, betOutcome) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return null;

    console.log("Fetching current price...");

    const [priceNumerator, priceDenominator] = await MMContract.getCurrentPrice(
      eventIndex,
      marketIndex,
      betOutcome
    );

    console.log("Current Price fetched successfully!");
    return {
      priceNumerator: ethers.utils.formatUnits(priceNumerator, 6).toString(),
      priceDenominator: ethers.utils.formatUnits(priceDenominator, 6).toString(),
    };
  } catch (error) {
    console.error("Error fetching current price:", error);
    toast.error(`Error fetching current price: ${error.reason}`);
    return null;
  }
};

export const createEvent = async (eventTitle, eventDescription) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return;

    console.log("Creating a new event...");

    const tx = await MMContract.createEvent(eventTitle, eventDescription);

    console.log("Transaction sent. Waiting for confirmation...");
    await tx.wait(); // Wait for the transaction to be mined
    console.log("Event created successfully!");

    // Log the transaction hash and event creation details
    console.log("Event Details:");
    console.log(`  Title: ${eventTitle}`);
    console.log(`  Description: ${eventDescription}`);
    toast.success("Event created successfully!");
  } catch (error) {
    console.error("Error creating event:", error);
    toast.error(`Error creating event: ${error.reason}`);
  }
};

export const addMarket = async (eventIndex, marketTitle, marketDescription) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return;

    console.log("Adding a new market...");

    const tx = await MMContract.createMarket(eventIndex, marketTitle, marketDescription);

    console.log("Transaction sent. Waiting for confirmation...");
    await tx.wait(); // Wait for the transaction to be mined
    console.log("Market added successfully!");

    // Log the transaction hash and market addition details
    console.log("Market Details:");
    console.log(`  Event Index: ${eventIndex}`);
    console.log(`  Market Title: ${marketTitle}`);
    console.log(`  Market Description: ${marketDescription}`);
    toast.success("Market added successfully!");
  } catch (error) {
    console.error("Error adding market:", error);
    toast.error(`Error adding market: ${error.reason}`);
  }
};

export const resolveMarket = async (eventIndex, marketIndex, winningOutcome) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return;

    console.log("Resolving market...");

    const tx = await MMContract.resolveMarket(eventIndex, marketIndex, winningOutcome);

    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait();

    console.log("Market resolved successfully!");
    console.log(`Transaction Hash: ${receipt.transactionHash}`);
    toast.success("Market resolved successfully!");
  } catch (error) {
    console.error("Error resolving market:", error);
    toast.error(`Error resolving market: ${error.reason}`);   
    throw error;
  }
};

export const cancelOrder = async (eventIndex, marketIndex, outcome, side, price, orderIndex) => {
  try {
    const { MMContract } = await initializeContracts();
    if (!MMContract) return;

    console.log("Canceling order...");

    const tx = await MMContract.cancelOrder(
      eventIndex,
      marketIndex,
      outcome,
      side,
      ethers.utils.parseUnits(price.toString(), 6),
      orderIndex
    );

    console.log("Transaction sent. Waiting for confirmation...");
    await tx.wait();

    console.log("Order canceled successfully!");
    toast.success("Order canceled successfully!");
  } catch (error) {
    console.error("Error canceling order:", error);
    toast.error(`Error canceling order: ${error.reason}`);
    return error;
  }
};