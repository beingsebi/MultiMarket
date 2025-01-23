import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";
import fs from "fs";

describe("Market", function () {
    let PriceHelper;
    let priceHelper;
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
    
        PriceHelper = await ethers.getContractFactory("PriceHelper");
        priceHelper = await PriceHelper.deploy(
            usdc.address,
            eventFactory.address,
            marketFactory.address,
            2,
            1,
            eventCreationFee,
            marketCreationFee
          );
          await priceHelper.deployed();
    
        // Transfer ownership of EventFactory to OrderPlacer
        const newOwner = priceHelper.address;
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
        await usdc.connect(addr1).approve(priceHelper.address, depositAmount);
        await priceHelper.connect(addr1).deposit(depositAmount);
    
        await usdc.transfer(addr2.address, depositAmount);
        await usdc.connect(addr2).approve(priceHelper.address, depositAmount);
        await priceHelper.connect(addr2).deposit(depositAmount);
    });

    async function createEventAndMarket(priceHelper, eventOwner) {
        const eventTitle = "Test Event";
        const eventDescription = "This is a test event description.";
        await priceHelper.connect(eventOwner).createEvent(eventTitle, eventDescription);

        const marketTitle = "Test Market";
        const marketDescription = "This is a test market description.";
        await priceHelper.connect(eventOwner).createMarket(0, marketTitle, marketDescription);
    }

    async function makeTransaction() {
        const shares = 10;
        const price = ethers.utils.parseUnits("0.6", 2);
        const opPrice = ethers.utils.parseUnits("0.4", 2);
    
        const tx = await priceHelper
          .connect(addr1)
          .placeLimitOrder(0, 0, BetOutcome.YES, OrderSide.BUY, price, shares);
        await tx.wait();
      
        const tx2 = await priceHelper
          .connect(addr2)
          .placeLimitOrder(0, 0, BetOutcome.NO, OrderSide.BUY, opPrice, shares);
        await tx2.wait();
    }

    it("only allow the owner to call resolveMarket", async function () {
        await createEventAndMarket(priceHelper, addr1);
        await expect(priceHelper.resolveMarket(0, 0, BetOutcome.YES)).to.be.revertedWith("Only the event owner can resolve markets");
    });

    it("can resolve a market", async function () {
        await createEventAndMarket(priceHelper, addr1);

        const tx = await priceHelper.connect(addr1).resolveMarket(0, 0, 0);
        await tx.wait();

        const event = await priceHelper.getEvent(0);
        expect(event[4][0]).to.be.true;
    });

    it("can sell winning shares", async function () {
        await createEventAndMarket(priceHelper, addr1);
        await makeTransaction();

        const tx = await priceHelper.connect(addr1).resolveMarket(0, 0, BetOutcome.YES);
        await tx.wait();

        const event = await priceHelper.getEvent(0);
        expect(event[4][0]).to.be.true;

        // winner sells shares
        const shares = 10;
        const price = ethers.utils.parseUnits("1", 2);
        const tx2 = await priceHelper
            .connect(addr1)
            .placeLimitOrder(0, 0, BetOutcome.YES, OrderSide.SELL, price, shares);
        await tx2.wait();
    
        const receipt = await tx2.wait();
    
        const orderPlaced = receipt.events.some(
          (event) => event.event === "LimitOrderPlaced"
        );
        expect(orderPlaced).to.be.true;
        const positionsAfter = await priceHelper.getPositions(0, addr1.address);
        expect(positionsAfter.map(p => p.toString())).to.deep.equal(["0", "0", "0", "0"]);
    });

    it("can't sell losing shares", async function () {
        await createEventAndMarket(priceHelper, addr1);
        await makeTransaction();

        const tx = await priceHelper.connect(addr1).resolveMarket(0, 0, BetOutcome.YES);
        await tx.wait();

        const event = await priceHelper.getEvent(0);
        expect(event[4][0]).to.be.true;

        // loser tries to sell shares
        const shares = 10;
        const price = ethers.utils.parseUnits("1", 2);
        const tx2 = await priceHelper.connect(addr2).placeLimitOrder(0, 0, BetOutcome.NO, OrderSide.SELL, price, shares);
        await tx2.wait();
    
        const receipt = await tx2.wait();
    
        const orderPlaced = receipt.events.some(
          (event) => event.event === "LimitOrderPlaced"
        );

        expect(orderPlaced).to.be.true;
        const positionsAfter = await priceHelper.getPositions(0, addr2.address);
        expect(positionsAfter.map(p => p.toString())).to.deep.equal(["0", "0", "0", shares.toString()]);
    });
});