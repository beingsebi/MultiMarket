import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";

describe("EventFactory contract", function () {
  let EventFactory;
  let eventFactory;
  let owner;
  let MarketFactory;
  let marketFactory;

  const eventTitle = "Test Event";
  const eventDescription = "A description of the test event";
  const decimals = 6;
  const granularity = 1000;

  beforeEach(async function () {
    const signers = await ethers.getSigners();
    owner = signers[0];

    // Deploy the EventFactory contract
    EventFactory = await ethers.getContractFactory("EventFactory");
    eventFactory = await EventFactory.deploy();
    await eventFactory.deployed();

    expect(eventFactory.address).to.not.equal(ethers.constants.AddressZero);

    MarketFactory = await ethers.getContractFactory("MarketFactory");
    marketFactory = await MarketFactory.deploy();
    await marketFactory.deployed();
  });

  describe("Event creation", function () {
    it("Should create a new event contract", async function () {
      const eventAddress = await eventFactory.createEvent(
        owner.address,
        marketFactory.address,
        decimals,
        granularity,
        eventTitle,
        eventDescription
      );

      expect(eventAddress).to.not.equal(ethers.constants.AddressZero);
    });
  });
});
