// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./01_TokenHolder.sol";

contract OrderBook is TokenHolder {
    event OrderPlaced(
        address indexed user,
        uint indexed orderId,
        BetOutcome betOutcome,
        OrderType orderType,
        uint price,
        uint shares
    );

    enum BetOutcome {
        Yes,
        No
    }

    enum OrderType {
        Buy,
        Sell
    }

    struct OrderIdentifier {
        BetOutcome betOutcome;
        OrderType orderType;
        uint price;
        uint indexInOrderBookArray;
    }

    struct Order {
        address user;
        uint shares;
        uint timestamp;
        bool isActive;
    }

    struct OrdersArray {
        uint firstActive;
        Order[] orders;
    }

    uint public firstActive;
    OrderIdentifier[] public orderIdentifiers;
    //// price 1 => 1e-6 tokens   |   [Yes/No][Buy/Sell][Price]
    mapping(BetOutcome => mapping(OrderType => mapping(uint => OrdersArray)))
        public orderBook;
    mapping(address => uint) public userActiveOrdersCount;

    constructor(
        address _currencyToken,
        uint16 _decimals
    ) TokenHolder(_currencyToken, _decimals) {}

    function placeLimitOrder(
        BetOutcome _betOutcome,
        OrderType _orderType,
        uint _price,
        uint _shares
    ) external {
        require(_shares > 0, "Shares must be greater than 0");
        require(
            _price > 0 && _price < 10 ** 6,
            "Price must be between 0 and 1000"
        );
        require(
            _getBalance(msg.sender) >= _shares * _price,
            "Insufficient balance"
        );

        OrderIdentifier memory orderIdentifier = OrderIdentifier(
            _betOutcome,
            _orderType,
            _price,
            orderBook[_betOutcome][_orderType][_price].orders.length
        );
        orderIdentifiers.push(orderIdentifier);

        Order memory order = Order(msg.sender, _shares, block.timestamp, true);

        orderBook[_betOutcome][_orderType][_price].orders.push(order);
        userActiveOrdersCount[msg.sender]++;

        emit OrderPlaced(
            msg.sender,
            orderIdentifiers.length - 1,
            _betOutcome,
            _orderType,
            _price,
            _shares
        );
    }
}
