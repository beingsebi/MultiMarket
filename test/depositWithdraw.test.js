// import pkg from "hardhat";
// const { ethers } = pkg;
// import { expect } from "chai";

// describe("TokenHolder contract", function () {
//   let TokenHolder;
//   let tokenHolder;
//   let USDC;
//   let usdc;
//   let owner;
//   let addr1;

//   const initialSupply = ethers.utils.parseUnits("1000", 6);
//   const depositAmount = ethers.utils.parseUnits("100", 6);

//   beforeEach(async function () {
//     const signers = await ethers.getSigners();
//     owner = signers[0];
//     addr1 = signers[1];

//     USDC = await ethers.getContractFactory("USDC");
//     usdc = await USDC.deploy(owner.address);
//     await usdc.deployed();

//     TokenHolder = await ethers.getContractFactory("TokenHolder");
//     tokenHolder = await TokenHolder.deploy(usdc.address, 6, 1);
//     await tokenHolder.deployed();

//     await usdc.transfer(addr1.address, depositAmount);
//     await usdc.connect(addr1).approve(tokenHolder.address, depositAmount);
//   });

//   describe("Deposit", function () {
//     it("Should deposit tokens into the contract and update the user's balance", async function () {
//       const initialBalance = await tokenHolder.freeBalances(addr1.address);
//       console.log("initialBalance   ", initialBalance.toString());

//       await tokenHolder.connect(addr1).deposit(depositAmount);

//       const newBalance = await tokenHolder.freeBalances(addr1.address);
//       expect(newBalance.sub(initialBalance).toString()).to.eq(
//         depositAmount.toString()
//       );
//     });
//   });
// });
import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";

describe("TokenHolder contract", function () {
  let TokenHolder;
  let tokenHolder;
  let USDC;
  let usdc;
  let owner;
  let addr1;

  const initialSupply = ethers.utils.parseUnits("1000", 6);
  const depositAmount = ethers.utils.parseUnits("100", 6);
  const withdrawAmount = ethers.utils.parseUnits("50", 6);

  beforeEach(async function () {
    const signers = await ethers.getSigners();
    owner = signers[0];
    addr1 = signers[1];

    USDC = await ethers.getContractFactory("USDC");
    usdc = await USDC.deploy(owner.address);
    await usdc.deployed();

    TokenHolder = await ethers.getContractFactory("TokenHolder");
    tokenHolder = await TokenHolder.deploy(usdc.address, 6, 1);
    await tokenHolder.deployed();

    await usdc.transfer(addr1.address, depositAmount);
    await usdc.connect(addr1).approve(tokenHolder.address, depositAmount);
  });

  describe("Deposit", function () {
    it("Should deposit tokens into the contract and update the user's balance", async function () {
      const initialBalance = await tokenHolder.freeBalances(addr1.address);
      console.log("initialBalance   ", initialBalance.toString());

      await tokenHolder.connect(addr1).deposit(depositAmount);

      const newBalance = await tokenHolder.freeBalances(addr1.address);
      expect(newBalance.sub(initialBalance).toString()).to.eq(
        depositAmount.toString()
      );
    });
  });

  describe("Withdraw", function () {
    it("Should withdraw tokens from the contract and update the user's balance", async function () {
      await tokenHolder.connect(addr1).deposit(depositAmount);

      const initialBalance = await tokenHolder.freeBalances(addr1.address);
      console.log("initialBalance   ", initialBalance.toString());

      await tokenHolder.connect(addr1).withdraw(withdrawAmount);

      const newBalance = await tokenHolder.freeBalances(addr1.address);
      expect(initialBalance.sub(newBalance).toString()).to.eq(
        withdrawAmount.toString()
      );
    });

    it("Should revert if there are insufficient funds", async function () {
      try {
        await tokenHolder.connect(addr1).withdraw(depositAmount.add(1));
        // If the line above doesn't throw, fail the test
        expect.fail("Expected transaction to revert, but it did not.");
      } catch (error) {
        expect(error.message).to.include("Insufficient balance");
      }
    });

    it("Should revert if the amount is zero", async function () {
      try {
        await tokenHolder.connect(addr1).withdraw(0);
        // If the line above doesn't throw, fail the test
        expect.fail("Expected transaction to revert, but it did not.");
      } catch (error) {
        expect(error.message).to.include("Amount must be greater than 0");
      }
    });

    it("Should transfer the correct amount to the user", async function () {
      const initialUsdcBalance = await usdc.balanceOf(addr1.address);

      await tokenHolder.connect(addr1).deposit(depositAmount);
      await tokenHolder
        .connect(addr1)
        .withdraw(ethers.utils.parseUnits("1", 6));

      const newUsdcBalance = await usdc.balanceOf(addr1.address);
      expect(newUsdcBalance.toString()).to.eq(
        ethers.utils.parseUnits("1", 6).toString()
      );
    });
  });
});
