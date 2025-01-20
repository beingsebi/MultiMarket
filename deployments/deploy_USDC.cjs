async function main() {
  const USDC = await ethers.getContractFactory("USDC");

  const acc = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
  const usdc = await USDC.deploy(acc);

  console.log("USDC Contract Deployed to Address:", usdc.address);
  console.log(' ');

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

  // usdc add=>0x5FbDB2315678afecb367f032d93F642f64180aa3