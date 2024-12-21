// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./OrderDefinitions.sol";

event DirectTrade(
    address indexed buyer,
    address indexed seller,
    BetOutcome indexed outcome,
    uint price,
    uint shares
);

event GeneratingTrade(
    address indexed buyer1,
    BetOutcome indexed outcome1,
    uint price1,
    address indexed buyer2,
    // BetOutcome outcome2, = opposite(outcome1)
    // uint price2, = 1 - price1
    uint matchedShares
);