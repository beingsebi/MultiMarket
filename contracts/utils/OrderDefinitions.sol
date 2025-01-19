// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

enum OrderType {
    Limit,
    Market
}

enum BetOutcome {
    Yes,
    No
}

enum OrderSide {
    Buy,
    Sell
}

struct Order {
    address user;
    uint initialShares;
    uint remainingShares;
    uint timestamp;
    bool isActive;
    // how much money the user received/spent till now
    uint currentTotalPrice;
    uint index;
}

struct OrderDto {
    uint initialShares;
    uint remainingShares;
    uint timestamp;
    uint totalCostOfFilledShares;
    uint price;
}
