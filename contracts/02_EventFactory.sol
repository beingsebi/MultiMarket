// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./01_TokenHolder.sol";

contract EventFactory is TokenHolder {
    event EventCreated(
        address indexed admin,
        uint eventIndex,
        string title,
        string description
    );

    uint public eventCreationFee;

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
        uint eventIndex;
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
        mapping(BetOutcome => mapping(OrderType => mapping(uint => Order[]))) orderBook;
        mapping(address => uint) userActiveOrdersCount;
    }

    struct Market {
        string title;
        string description;
        OrderBook orderBook;
    }

    struct Event {
        string title;
        string description;
        Market[] markets;
    }

    Event[] public events;
    mapping(uint => address) public eventToAdmin;
    mapping(address => uint) public adminEventCount;

    constructor(
        address _currencyToken,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee
    ) TokenHolder(_currencyToken, _decimals, _granularity) {
        eventCreationFee = _eventCreationFee;
        contractBalance = 0;
    }

    function createEvent(
        string memory _eventTitle,
        string memory _eventDescription,
        string memory _firstMarketTitle,
        string memory _firstMarketDescription
    ) external {
        require(
            _getBalance(msg.sender) >= eventCreationFee,
            "Insufficient balance"
        );
        Event storage event_ = events.push();
        event_.title = _eventTitle;
        event_.description = _eventDescription;
        eventToAdmin[events.length - 1] = msg.sender;
        adminEventCount[msg.sender]++;

        Market storage market = event_.markets.push();
        market.title = _firstMarketTitle;
        market.description = _firstMarketDescription;

        balances[msg.sender] -= eventCreationFee;
        contractBalance += eventCreationFee;

        emit EventCreated(
            msg.sender,
            events.length - 1,
            _eventTitle,
            _eventDescription
        );
    }

    function getEventWithMarkets(
        uint _eventIndex
    )
        external
        view
        returns (string memory, string memory, string[] memory, string[] memory)
    {
        Event storage event_ = events[_eventIndex];
        uint marketsCount = event_.markets.length;
        string[] memory titles = new string[](marketsCount);
        string[] memory descriptions = new string[](marketsCount);

        for (uint i = 0; i < marketsCount; i++) {
            titles[i] = event_.markets[i].title;
            descriptions[i] = event_.markets[i].description;
        }

        return (event_.title, event_.description, titles, descriptions);
    }
}
// function _placeLimitBuyOrder(
//     BetOutcome _betOutcome,
//     OrderType _orderType,
//     uint _price,
//     uint _shares
// ) internal {
//     require(
//         _getBalance(msg.sender) >= _shares * _price,
//         "Insufficient balance"
//     );

//     OrderIdentifier memory orderIdentifier = OrderIdentifier(
//         _betOutcome,
//         _orderType,
//         _price,
//         orderBook[_betOutcome][_orderType][_price].length
//     );
//     orderIdentifiers.push(orderIdentifier);

//     Order memory order = Order(msg.sender, _shares, block.timestamp, true);

//     orderBook[_betOutcome][_orderType][_price].orders.push(order);
//     userActiveOrdersCount[msg.sender]++;

//     emit OrderPlaced(
//         msg.sender,
//         orderIdentifiers.length - 1,
//         _betOutcome,
//         _orderType,
//         _price,
//         _shares
//     );

//     // do order matching
// }

// function placeLimitOrder(
//     BetOutcome _betOutcome,
//     OrderType _orderType,
//     uint _price,
//     uint _shares
// ) external {
//     require(_shares > 0, "Shares must be greater than 0");
//     require(
//         _price > 0 && _price < 10 ** decimals,
//         "Price must be between 0 and 1 (* 10^decimals)"
//     );
//     require(
//         _price % (10 ** granularity) == 0,
//         "Price must be a multiple of 10^granularity"
//     );

//     require(
//         _betOutcome == BetOutcome.Yes || _betOutcome == BetOutcome.No,
//         "Invalid bet outcome"
//     );
//     require(
//         _orderType == OrderType.Buy || _orderType == OrderType.Sell,
//         "Invalid order type"
//     );

//     if (_orderType == OrderType.Buy) {
//         _placeLimitBuyOrder(_betOutcome, _orderType, _price, _shares);
//     } else if (_orderType == OrderType.Sell) {
//         _placeLimitSellOrder(_betOutcome, _orderType, _price, _shares);
//     }
// }

// function getUserOrders() external view returns (OrderIdentifier[] memory) {
//     OrderIdentifier[] memory userOrders = new OrderIdentifier[](
//         userActiveOrdersCount[msg.sender]
//     );

//     uint userOrdersIndex = 0;
//     for (
//         uint i = firstActive;
//         i < orderIdentifiers.length &&
//             userOrdersIndex < userActiveOrdersCount[msg.sender];
//         i++
//     ) {
//         OrderIdentifier memory orderIdentifier = orderIdentifiers[i];
//         Order memory order = orderBook[orderIdentifier.betOutcome][
//             orderIdentifier.orderType
//         ][orderIdentifier.price].orders[
//                 orderIdentifier.indexInOrderBookArray
//             ];

//         if (order.user == msg.sender && order.isActive) {
//             userOrders[userOrdersIndex] = orderIdentifier;
//             userOrdersIndex++;
//         }
//     }

//     return userOrders;
// }
// }
