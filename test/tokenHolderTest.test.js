import pkg from "hardhat";
const { ethers } = pkg;
import { expect } from "chai";

// import "@nomicfoundation/hardhat-chai-matchers";

describe("USDC contract", function () {
  let USDC;
  let usdc;
  let owner;
  let addr1;
  let addr2;

  //42e9 (* 1e6 deicmals)=42e15
  const initialSupply = ethers.utils.parseUnits("42", 15); // 42 million tokens with 18 decimals
  const transferAmount = ethers.utils.parseUnits("100", 6); // Transfer 100 tokens with 6 decimals

  beforeEach(async function () {
    const signers = await ethers.getSigners();

    owner = signers[0];  
    addr1 = signers[1];  
    addr2 = signers[2];   

    USDC = await ethers.getContractFactory("USDC");
    usdc = await USDC.deploy(owner.address);
    await usdc.deployed();
  });

  describe("Deployment", function () {
    it("Should assign the initial supply to the owner", async function () {
      const balance = await usdc.balanceOf(owner.address);
      console.log("Owner balance:", balance.toString());
      expect(balance.toString()).to.eq(initialSupply.toString());  // Use .eq for BigNumber comparison
    });

    it("Should have 6 decimals", async function () {
      const decimals = await usdc.decimals();
      expect(decimals).to.eq(6);
    });
  });

  describe("Transfers", function () {
  it("Should transfer tokens between accounts", async function () {

    const initialOwnerBalance = await usdc.balanceOf(owner.address);
    const initialAddr1Balance = await usdc.balanceOf(addr1.address);
    console.log("initialOwnerBalance   ", initialOwnerBalance);
    await usdc.transfer(addr1.address, transferAmount);

    const finalOwnerBalance = await usdc.balanceOf(owner.address);
    const finalAddr1Balance = await usdc.balanceOf(addr1.address);

    expect(finalOwnerBalance.toString()).to.eq(initialOwnerBalance.sub(transferAmount).toString());
    expect(finalAddr1Balance.toString()).to.eq(initialAddr1Balance.add(transferAmount).toString());
  });

  // it("Should fail if sender doesn’t have enough tokens", async function () {
  //   const initialOwnerBalance = await usdc.balanceOf(owner.address);

  //   // Try to send 1 token from addr1 (0 tokens) to owner (42 million tokens).
  //   await expect(
  //     usdc.connect(addr1).transfer(owner.address, transferAmount)
  //   ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

  //   // Owner balance shouldn't have changed.
  //   expect(await usdc.balanceOf(owner.address)).to.eq(initialOwnerBalance);
  // });

  });
});


