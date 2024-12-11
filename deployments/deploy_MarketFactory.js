async function main() {
  const MarketFactory = await ethers.getContractFactory("MarketFactory");

  const marketFactory = await MarketFactory.deploy();

  console.log("Market Factory Contract Deployed to Address:", marketFactory.address);
  console.log(' ');

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

  