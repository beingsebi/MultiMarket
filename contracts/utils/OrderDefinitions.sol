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
    uint currentTotalPrice;
    // how much money the user received/spent till now
}
