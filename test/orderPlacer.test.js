import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";
import fs from "fs";

describe("OrderPlacer contract", function () {
  let OrderPlacer;
  let orderPlacer;
  let USDC;
  let usdc;
  let EventFactory;
  let eventFactory;
  let MarketFactory;
  let marketFactory;
  let owner;
  let addr1, addr2;

  const eventCreationFee = ethers.utils.parseUnits("10", 6);
  const marketCreationFee = ethers.utils.parseUnits("5", 6);
  const depositAmount = ethers.utils.parseUnits("100", 6);

  const BetOutcome = {
    YES: 0,
    NO: 1,
  };

  const OrderSide = {
    BUY: 0,
    SELL: 1,
  };

  beforeEach(async function () {
    const signers = await ethers.getSigners();
    owner = signers[0];
    addr1 = signers[1];
    addr2 = signers[2];

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

    // Deploy the OrderPlacer contract
    OrderPlacer = await ethers.getContractFactory("OrderPlacer");
    orderPlacer = await OrderPlacer.deploy(
      usdc.address,
      eventFactory.address,
      marketFactory.address,
      6,
      1,
      eventCreationFee,
      marketCreationFee
    );
    await orderPlacer.deployed();

    // Transfer ownership of EventFactory to OrderPlacer
    const newOwner = orderPlacer.address;
    const eventFactoryAddress = eventFactory.address;
    const eventFactoryABI = JSON.parse(
      fs.readFileSync(process.env.EVENT_FACTORY_ABI_PATH)
    ).abi;

    const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    const eventFactoryContract = new ethers.Contract(
      eventFactoryAddress,
      eventFactoryABI,
      wallet
    );
    const transferTx = await eventFactoryContract.transferOwnership(newOwner);
    await transferTx.wait();

    await usdc.transfer(addr1.address, depositAmount);
    await usdc.connect(addr1).approve(orderPlacer.address, depositAmount);
    await orderPlacer.connect(addr1).deposit(depositAmount);

    await usdc.transfer(addr2.address, depositAmount);
    await usdc.connect(addr2).approve(orderPlacer.address, depositAmount);
    await orderPlacer.connect(addr2).deposit(depositAmount);
  });

  async function createEventAndMarket(orderPlacer, addr1) {
    const eventTitle = "Test Event";
    const eventDescription = "This is a test event description.";
    await orderPlacer.connect(addr1).createEvent(eventTitle, eventDescription);

    const marketTitle = "Test Market";
    const marketDescription = "This is a test market description.";
    await orderPlacer.connect(addr1).createMarket(0, marketTitle, marketDescription);
  }

  it("Should place a limit order", async function () {
    await createEventAndMarket(orderPlacer, addr1);

    // Place a limit order
    const betOutcome = BetOutcome.YES; 
    const orderSide = OrderSide.BUY;
    const price = ethers.utils.parseUnits("1", 6); // Example price
    const shares = 10;

    const tx = await orderPlacer
      .connect(addr1)
      .placeLimitOrder(0, 0, betOutcome, orderSide, price, shares);
    const receipt = await tx.wait();
    const orderPlaced = receipt.events.some(
      (event) => event.event === "LimitOrderPlaced"
    );
    expect(orderPlaced).to.be.true;
  });

  it("Should place a market order", async function () {
    await createEventAndMarket(orderPlacer, addr1);

    // Place a market order
    const betOutcome = BetOutcome.YES;
    const orderSide = OrderSide.BUY;
    const shares = 10;

    const tx = await orderPlacer
      .connect(addr1)
      .placeMarketOrderByShares(0, 0, betOutcome, orderSide, shares);
    const receipt = await tx.wait();

    const marketOrderEvent = receipt.events.find(
      (event) => event.event === "MarketOrderPlaced"
    );
    const filledShares = marketOrderEvent.args.filledShares.toNumber();
    const totalCostOfFilledShares =
      marketOrderEvent.args.totalCostOfFilledShares.toNumber();
    const unfilledShares = marketOrderEvent.args.unfilledShares.toNumber();
    expect(filledShares).to.equal(0);
    expect(totalCostOfFilledShares).to.equal(0);
    expect(unfilledShares).to.equal(shares);
  });

  it("Cannot sell more shares than owned free shares", async function () {
    await createEventAndMarket(orderPlacer, addr1);

    await expect(
      orderPlacer.connect(addr1).placeLimitOrder(0, 0, BetOutcome.YES, OrderSide.SELL, ethers.utils.parseUnits("1", 6), 1)
    ).to.be.revertedWith("Insufficient free shares");
  });

  it("match two opposite limit orders", async function () {
    await createEventAndMarket(orderPlacer, addr1);

    // Place first limit order
    const shares = 10;
    const price = ethers.utils.parseUnits("0.6", 6);
    const opPrice = ethers.utils.parseUnits("0.4", 6);

    const tx = await orderPlacer
      .connect(addr1)
      .placeLimitOrder(0, 0, BetOutcome.YES, OrderSide.BUY, price, shares);
    await tx.wait();

    const positionsBefore = await orderPlacer.getPositions(0, addr1.address);
    expect(positionsBefore.map(p => p.toString())).to.deep.equal(["0", "0", "0", "0"]); // No match yet,
  
    // Place second limit order  
    const tx2 = await orderPlacer
      .connect(addr2)
      .placeLimitOrder(0, 0, BetOutcome.NO, OrderSide.BUY, opPrice, shares);
    await tx2.wait();

    const positionsAfter = await orderPlacer.getPositions(0, addr1.address);
    expect(positionsAfter.map(p => p.toString())).to.deep.equal(["10", "0", "0", "0"]);

    const positionsAfterAddr2 = await orderPlacer.getPositions(0, addr2.address);
    expect(positionsAfterAddr2.map(p => p.toString())).to.deep.equal(["0", "0", "10", "0"]);
  });

  it("can sell just brought shares", async function () {
    await createEventAndMarket(orderPlacer, addr1);

    // Place first limit order
    const shares = 10;
    const price = ethers.utils.parseUnits("0.6", 6);
    const opPrice = ethers.utils.parseUnits("0.4", 6);

    const tx = await orderPlacer
      .connect(addr1)
      .placeLimitOrder(0, 0, BetOutcome.YES, OrderSide.BUY, price, shares);
    await tx.wait();
  
    // Place second limit order  
    const tx2 = await orderPlacer
      .connect(addr2)
      .placeLimitOrder(0, 0, BetOutcome.NO, OrderSide.BUY, opPrice, shares);
    await tx2.wait();

    const tx3 = await orderPlacer
      .connect(addr1)
      .placeLimitOrder(0, 0, BetOutcome.YES, OrderSide.SELL, price, shares);
    const receipt = await tx3.wait();
    const orderPlaced = receipt.events.some(
      (event) => event.event === "LimitOrderPlaced"
    );
    expect(orderPlaced).to.be.true;
  });

});
