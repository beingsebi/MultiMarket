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

