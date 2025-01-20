#!/bin/bash

# Remove existing build artifacts and cache
rm -rf artifacts/
rm -rf cache/

# Compile the Hardhat project
npx hardhat compile

# Deploy USDC contract to the localhost network
npx hardhat run deployments/deploy_USDC.cjs --network localhost

# Deploy the EventFactory contract to the localhost network
npx hardhat run deployments/deploy_EventFactory.cjs --network localhost

# Deploy the MarketFactory contract to the localhost network
npx hardhat run deployments/deploy_MarketFactory.cjs --network localhost

# Deploy the main contract to the localhost network
npx hardhat run deployments/deploy.cjs --network localhost

# Transfer ownership of the EventFactory contracts to the main contract
npx hardhat run scripts/transferEventFactoryOwnership.cjs --network localhost
# important to have this after deployment

# Deposit USDC to the main contract
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e npx hardhat run scripts/deposit.cjs --network localhost
# Deposit 2
PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 npx hardhat run scripts/deposit.cjs --network localhost

# Get the balance of user 1
PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getBalance.cjs --network localhost

# Get the balance of user 2
# PUBLIC_ADDRESS=0xdD2FD4581271e230360230F9337D5c0430Bf44C0 npx hardhat run scripts/getBalance.cjs --network localhost

# withdraw
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e npx hardhat run scripts/withdraw.cjs --network localhost

# Get the balance of the user
PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getBalance.cjs --network localhost

# Echo a message indicating the deployment is complete
echo "!!!"
echo "Deployment and initial setup complete."
echo "!!!"
echo " "

# Create an event
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e npx hardhat run scripts/createEvent.cjs --network localhost

# Create 2 markets
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e npx hardhat run scripts/createMarket.cjs --network localhost
# npx hardhat run scripts/createMarket.cjs --network localhost

# Get the event
npx hardhat run scripts/getEvent.cjs --network localhost

# Get all events
npx hardhat run scripts/getAllEvents.cjs --network localhost

# Get the market
npx hardhat run scripts/getMarket.cjs --network localhost

echo "!!!"
echo "finished creating event and markets"
echo "!!!"
echo " "


PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e OUTCOME=0 PRICE=400000 SHARES=10 npx hardhat run scripts/placeLimitBuyOrder.cjs --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 OUTCOME=1 PRICE=600000 SHARES=10 npx hardhat run scripts/placeLimitBuyOrder.cjs --network localhost

# PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e OUTCOME=0 npx hardhat run scripts/resolveMarket.cjs --network localhost

echo "!!!"
echo "testing phase 2 completed. shares were issued"
echo "!!!"
echo " "

# Get the positions
PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getPositions.cjs --network localhost


# sell order
PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e OUTCOME=0 PRICE=400000 SHARES=5 npx hardhat run scripts/placeLimitSellOrder.cjs --network localhost

echo " "
echo "here"
echo " "

PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 OUTCOME=0 SIDE=1 npx hardhat run scripts/getActiveOrders.cjs --network localhost

PRIVATE_KEY=df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e OUTCOME=0 PRICE=400000 ORDER_INDEX=0 SIDE=1 npx hardhat run scripts/cancelOrder.cjs --network localhost

PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 OUTCOME=0 SIDE=1 npx hardhat run scripts/getActiveOrders.cjs --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 OUTCOME=0 SIDE=0 SHARES=2 npx hardhat run scripts/placeMarketOrder.cjs --network localhost

PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getPositions.cjs --network localhost

# Get the positions
PUBLIC_ADDRESS=0xdD2FD4581271e230360230F9337D5c0430Bf44C0 npx hardhat run scripts/getPositions.cjs --network localhost

PRIVATE_KEY=de9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0 OUTCOME=0 PRICE=600000 SHARES=7 npx hardhat run scripts/placeLimitBuyOrder.cjs --network localhost

echo "!!!"
echo "  "

PUBLIC_ADDRESS=0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 npx hardhat run scripts/getPositions.cjs --network localhost

PUBLIC_ADDRESS=0xdD2FD4581271e230360230F9337D5c0430Bf44C0 npx hardhat run scripts/getPositions.cjs --network localhost
