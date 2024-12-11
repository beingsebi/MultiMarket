async function main() {
  const MultiMarket = await ethers.getContractFactory("EventHelper");

  const usdcAddress = process.env.USDC_ADDRESS;
  const eventFactoryAddress = process.env.EVENT_FACTORY_ADDRESS;

  // usdc address, decimals,granularity,fee
  var decimals = 6;
  var granularity = 3;
  var eventFee = 30 * 10 ** decimals;
  var marketFee = 10 * 10 ** decimals;

  const multiMarket = await MultiMarket.deploy(
    usdcAddress,
    eventFactoryAddress,
    decimals,
    granularity,
    eventFee,
    marketFee
  );

  console.log("Contract Deployed to Address:", multiMarket.address);
  console.log(' ');

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
