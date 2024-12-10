async function main() {
  const MultiMarket = await ethers.getContractFactory("OrderPlacer");

  // const usdcAddress = process.env.USDC_ADDRESS;
  const usdcAddress="0x5FbDB2315678afecb367f032d93F642f64180aa3"

  // usdc address, decimals,granularity,fee
  var decimals = 6;
  var granularity = 3;
  var eventFee = 30 * (10 ** decimals);
  var marketFee = 10 * (10 ** decimals);
  const multiMarket = await MultiMarket.deploy(usdcAddress, decimals, granularity, eventFee, marketFee);

  console.log("Contract Deployed to Address:", multiMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
