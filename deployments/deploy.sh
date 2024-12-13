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
npx hardhat run scripts/deposit.js --network localhost

# Get the balance of the user
npx hardhat run scripts/getBalance.js --network localhost

# withdraw
npx hardhat run scripts/withdraw.js --network localhost

# Get the balance of the user
npx hardhat run scripts/getBalance.js --network localhost

# Echo a message indicating the deployment is complete
echo "!!!"
echo "Deployment and initial setup complete."
echo "!!!"
echo " "


# Create an event
npx hardhat run scripts/createEvent.js --network localhost


# Create 2 markets
npx hardhat run scripts/createMarket.js --network localhost
npx hardhat run scripts/createMarket.js --network localhost


# Get the event
npx hardhat run scripts/getEvent.js --network localhost


# Get the market
npx hardhat run scripts/getMarket.js --network localhost

npx hardhat run scripts/placeLimitBuyOrder.js --network localhost

npx hardhat run scripts/placeLimitSellOrder.js --network localhost