async function main() {
  const MultiMarket = await ethers.getContractFactory("MultiMarket");

  const usdcAddress = process.env.USDC_ADDRESS;

  const multiMarket = await MultiMarket.deploy(usdcAddress);

  console.log("Contract Deployed to Address:", multiMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
