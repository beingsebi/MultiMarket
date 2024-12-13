// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/OrderDefinitions.sol";

contract Market is Ownable {
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;

    string public title;
    string public description;
    uint public issuedShares;

    // [Yes/No][Buy/Sell][Price][OrderIndex]
    mapping(BetOutcome => mapping(OrderSide => mapping(uint => Order[]))) orderBook;
    mapping(address => uint) userActiveOrdersCount;

    // shares = free + reserved
    mapping(BetOutcome => mapping(address => uint)) freeShares;
    mapping(BetOutcome => mapping(address => uint)) reservedShares;

    mapping(BetOutcome => BetOutcome) oppositeBetOutcome;

    constructor(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description
    ) Ownable(_owner) {
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;

        oppositeBetOutcome[BetOutcome.Yes] = BetOutcome.No;
        oppositeBetOutcome[BetOutcome.No] = BetOutcome.Yes;
    }

    /**
     * @notice Returns the market's title and description.
     * @return The market's title and description.
     */
    function getMarket() external view returns (string memory, string memory) {
        return (title, description);
    }

    function placeLimitBuyOrder(
        address user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external onlyOwner {
        Order memory order = Order({
            user: user,
            initialShares: _shares,
            remainingShares: _shares,
            timestamp: block.timestamp,
            isActive: true
        });

        orderBook[_outcome][OrderSide.Buy][_price].push(order);
        userActiveOrdersCount[user]++;

        _tryToMatchBuyOrder(
            _outcome,
            _price,
            orderBook[_outcome][OrderSide.Buy][_price].length - 1
        );
    }

    function placeLimitSellOrder(
        address user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external onlyOwner {
        require(
            freeShares[_outcome][user] >= _shares,
            "Insufficient free shares"
        );

        Order memory order = Order({
            user: user,
            initialShares: _shares,
            remainingShares: _shares,
            timestamp: block.timestamp,
            isActive: true
        });

        freeShares[_outcome][user] -= _shares;
        reservedShares[_outcome][user] += _shares;

        orderBook[_outcome][OrderSide.Sell][_price].push(order);
        userActiveOrdersCount[user]++;

        _tryToMatchSellOrder(
            _outcome,
            _price,
            orderBook[_outcome][OrderSide.Sell][_price].length - 1
        );
    }

    function _tryToMatchBuyOrder(
        BetOutcome _outcome,
        uint _price,
        uint _orderIndex
    ) private {
        Order storage order = orderBook[_outcome][OrderSide.Buy][_price][
            _orderIndex
        ];

        //match buy order with sell order
        for (
            uint _tryPrice = 0;
            _tryPrice <= _price && order.remainingShares > 0;
            _tryPrice++
        ) {
            for (
                uint _tryIndexInOB = 0;
                _tryIndexInOB <
                orderBook[_outcome][OrderSide.Sell][_tryPrice].length &&
                    order.remainingShares > 0;
                _tryIndexInOB++
            ) {
                Order storage _tryOrder = orderBook[_outcome][OrderSide.Sell][
                    _tryPrice
                ][_tryIndexInOB];

                if (_tryOrder.isActive) {
                    uint _matchedShares = order.remainingShares <
                        _tryOrder.remainingShares
                        ? order.remainingShares
                        : _tryOrder.remainingShares;

                    //execute direct trade
                    // also do -=rem_shares
                }
            }
        }

        // match buy order with buy order of opposite outcome
        BetOutcome _oppositeOutcome = oppositeBetOutcome[_outcome];
        uint _oppositePrice = 10 ** decimals - _price;

        for (
            uint _tryIndexInOB = 0;
            _tryIndexInOB <
            orderBook[_oppositeOutcome][OrderSide.Buy][_oppositePrice].length &&
                order.remainingShares > 0;
            _tryIndexInOB++
        ) {
            Order storage _tryOrder = orderBook[_oppositeOutcome][
                OrderSide.Buy
            ][_oppositePrice][_tryIndexInOB];

            if (_tryOrder.isActive) {
                uint _matchedShares = order.remainingShares <
                    _tryOrder.remainingShares
                    ? order.remainingShares
                    : _tryOrder.remainingShares;

                //execute generating trade
                // also do -=rem_shares
            }
        }
    }

    function _tryToMatchSellOrder(
        BetOutcome _outcome,
        uint _price,
        uint _orderIndex
    ) private {
        Order storage order = orderBook[_outcome][OrderSide.Sell][_price][
            _orderIndex
        ];

        //match sell order with buy order
        for (
            uint _tryPrice = 10 ** decimals;
            _tryPrice >= _price && order.remainingShares > 0;
            _tryPrice--
        ) {
            for (
                uint _tryIndexInOB = 0;
                _tryIndexInOB <
                orderBook[_outcome][OrderSide.Buy][_tryPrice].length &&
                    order.remainingShares > 0;
                _tryIndexInOB++
            ) {
                Order storage _tryOrder = orderBook[_outcome][OrderSide.Buy][
                    _tryPrice
                ][_tryIndexInOB];

                if (_tryOrder.isActive) {
                    uint _matchedShares = order.remainingShares <
                        _tryOrder.remainingShares
                        ? order.remainingShares
                        : _tryOrder.remainingShares;

                    //execute direct trade
                    // also do -=rem_shares
                }
            }
        }
    }
}
