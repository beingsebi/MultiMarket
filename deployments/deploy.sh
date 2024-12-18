#!/bin/bash

# Remove existing build artifacts and cache
rm -rf artifacts/
rm -rf cache/

# Compile the Hardhat project
npx hardhat compile

# Deploy USDC contract to the localhost network
npx hardhat run deployments/deploy_USDC.js --network localhost

# Deploy the EventFactory contract to the localhost network
npx hardhat run deployments/deploy_EventFactory.js --network localhost

# Deploy the MarketFactory contract to the localhost network
npx hardhat run deployments/deploy_MarketFactory.js --network localhost

# Deploy the main contract to the localhost network
npx hardhat run deployments/deploy.js --network localhost

# Deposit USDC to the main contract
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e npx hardhat run scripts/deposit.js --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 npx hardhat run scripts/deposit.js --network localhost

# Get the balance of user 1
PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getBalance.js --network localhost

# Get the balance of user 2
PUBLIC_ADDRESS=0xdD2FD4581271e230360230F9337D5c0430Bf44C0 npx hardhat run scripts/getBalance.js --network localhost

# withdraw
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e npx hardhat run scripts/withdraw.js --network localhost

# Get the balance of the user
PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getBalance.js --network localhost

# Echo a message indicating the deployment is complete
echo "!!!"
echo "Deployment and initial setup complete."
echo "!!!"
echo " "


# Create an event
npx hardhat run scripts/createEvent.js --network localhost


# Create 2 markets
npx hardhat run scripts/createMarket.js --network localhost
# npx hardhat run scripts/createMarket.js --network localhost


# Get the event
npx hardhat run scripts/getEvent.js --network localhost

# Get all events
npx hardhat run scripts/getAllEvents.js --network localhost

npx hardhat run scripts/getAllMarkets.js --network localhost

# Get the market
npx hardhat run scripts/getMarket.js --network localhost

PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e OUTCOME=0 PRICE=400000 SHARES=10 npx hardhat run scripts/placeLimitBuyOrder.js --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 OUTCOME=1 PRICE=600000 SHARES=10 npx hardhat run scripts/placeLimitBuyOrder.js --network localhost


echo "!!!"
echo "testing phase 2 completed. shares were issued"
echo "!!!"
echo " "

# Get the positions
PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getPositions.js --network localhost

# sell order
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e OUTCOME=0 PRICE=400000 SHARES=5 npx hardhat run scripts/placeLimitSellOrder.js --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 OUTCOME=0 SIDE=0 SHARES=2 npx hardhat run scripts/placeMarketOrder.js --network localhost

PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getPositions.js --network localhost


# Get the positions
PUBLIC_ADDRESS=0xdD2FD4581271e230360230F9337D5c0430Bf44C0 npx hardhat run scripts/getPositions.js --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 OUTCOME=0 PRICE=600000 SHARES=7 npx hardhat run scripts/placeLimitBuyOrder.js --network localhost

echo "!!!"
echo "  "

PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getPositions.js --network localhost

PUBLIC_ADDRESS=0xdD2FD4581271e230360230F9337D5c0430Bf44C0 npx hardhat run scripts/getPositions.js --network localhost
