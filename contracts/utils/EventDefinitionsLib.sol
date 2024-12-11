// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

library EventDefinitionsLib {
    enum BetOutcome {
        Yes,
        No
    }

    enum OrderType {
        Buy,
        Sell
    }

    struct OrderIdentifier {
        uint eventIndex;
        uint marketIndex;
        BetOutcome betOutcome;
        OrderType orderType;
        uint price;
        uint orderIndex;
    }

    struct Order {
        address user;
        uint shares;
        uint timestamp;
        bool isActive;
    }

    struct OrderBook {
        OrderIdentifier[] orderIdentifiers;
        //// price 1 => 10^-decimals tokens   |   [Yes/No][Buy/Sell][Price]
        mapping(BetOutcome => mapping(OrderType => mapping(uint => Order[]))) ob;
        mapping(address => uint) userActiveOrdersCount;
    }

    struct Market {
        string title;
        string description;
        OrderBook orderBook;
        uint issuedShares;
        mapping(BetOutcome => mapping(address => uint)) shares;
        mapping(BetOutcome => mapping(address => uint)) reservedShares;
    }

    struct Event {
        string title;
        string description;
        Market[] markets;
    }
}
