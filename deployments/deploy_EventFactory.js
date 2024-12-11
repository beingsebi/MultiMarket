async function main() {
  const EventFactory = await ethers.getContractFactory("EventFactory");

  const eventFactory = await EventFactory.deploy();

  console.log("Event Factory Contract Deployed to Address:", eventFactory.address);
  console.log(' ');

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

  // usdc add=>0x5FbDB2315678afecb367f032d93F642f64180aa3