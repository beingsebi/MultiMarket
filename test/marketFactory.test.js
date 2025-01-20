import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";

describe("MarketFactory contract", function () {
  let MarketFactory;
  let marketFactory;
  let USDC;
  let usdc;
  let owner;

  const marketTitle = "Test Markeasdasdasdast";
  const marketDescription = "A description of the test markadadsdasdasdsaet";
  const decimals = 6;
  const granularity = 1000;

  beforeEach(async function () {
    const signers = await ethers.getSigners();
    owner = signers[0];

    USDC = await ethers.getContractFactory("USDC");
    usdc = await USDC.deploy(owner.address); // Assuming the constructor takes the owner address
    await usdc.deployed();


    // Deploy the MarketFactory contract
    MarketFactory = await ethers.getContractFactory("MarketFactory");
    marketFactory = await MarketFactory.deploy();
    await marketFactory.deployed();


    expect(marketFactory.address).to.not.equal(ethers.constants.AddressZero);
  });

  describe("Market creation", function () {
    
    it("Should create a new market contract", async function () {
      const marketAddress = await marketFactory.createMarket(
        owner.address,
        decimals,
        granularity,
        marketTitle,
        marketDescription,
        usdc.address // Pass the address of the deployed USDC contract
      );

    expect(marketAddress).to.not.equal(ethers.constants.AddressZero);

    });
  });
});
