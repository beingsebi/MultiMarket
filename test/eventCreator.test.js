import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";
import fs from "fs";

describe("MarketCreator contract", function () {
  let MarketCreator;
  let marketCreator;
  let USDC;
  let usdc;
  let EventFactory;
  let eventFactory;
  let MarketFactory;
  let marketFactory;
  let owner;
  let addr1;

  const eventCreationFee = ethers.utils.parseUnits("10", 6);
  const marketCreationFee = ethers.utils.parseUnits("5", 6);
  const depositAmount = ethers.utils.parseUnits("100", 6);

  beforeEach(async function () {
    const signers = await ethers.getSigners();
    owner = signers[0];
    addr1 = signers[1];

    // Deploy the USDC contract
    USDC = await ethers.getContractFactory("USDC");
    usdc = await USDC.deploy(owner.address);
    await usdc.deployed();

    // Deploy the EventFactory contract (mock)
    EventFactory = await ethers.getContractFactory("EventFactory");
    eventFactory = await EventFactory.deploy();
    await eventFactory.deployed();

    // Deploy the MarketFactory contract (mock)
    MarketFactory = await ethers.getContractFactory("MarketFactory");
    marketFactory = await MarketFactory.deploy();
    await marketFactory.deployed();

    // Deploy the MarketCreator contract
    MarketCreator = await ethers.getContractFactory("MarketCreator");
    marketCreator = await MarketCreator.deploy(
      usdc.address,
      eventFactory.address,
      marketFactory.address,
      6,
      1,
      eventCreationFee,
      marketCreationFee
    );
    await marketCreator.deployed();


     const newOwner = marketCreator.address;

     const eventFactoryAddress = eventFactory.address;
     const eventFactoryABI = JSON.parse(
       fs.readFileSync(process.env.EVENT_FACTORY_ABI_PATH)
     ).abi;
     
     const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);
     
     const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
     
     const eventFactoryContract = new ethers.Contract(eventFactoryAddress, eventFactoryABI, wallet);
    const transferTx = await eventFactoryContract.transferOwnership(newOwner);
    await transferTx.wait();




    await usdc.transfer(addr1.address, depositAmount);
    await usdc.connect(addr1).approve(marketCreator.address, depositAmount);
    await marketCreator.connect(addr1).deposit(depositAmount);
  });

  describe("Event Creation", function () {
    it("Should create event", async function () {
      const initialBalance = await marketCreator.freeBalances(addr1.address);
      const eventTitle = "Test Event";
      const eventDescription = "This is a test event.a test event.a test event.";

      // Listen for the EventCreated event
    const success = await marketCreator
      .connect(addr1)
      .createEvent(eventTitle, eventDescription);
    const receipt = await success.wait();
    const eventCreated = receipt.events.some(event => event.event === "EventCreated");
        expect(eventCreated).to.be.true;
    });
  });
});
