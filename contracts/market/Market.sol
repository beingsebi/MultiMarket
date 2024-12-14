// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/OrderDefinitions.sol";
import "./ITokenHolder.sol";
import "hardhat/console.sol";

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
    ITokenHolder private tokenHolder;

    constructor(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description,
        address _tokenHolderAddress
    ) Ownable(_owner) {
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;

        oppositeBetOutcome[BetOutcome.Yes] = BetOutcome.No;
        oppositeBetOutcome[BetOutcome.No] = BetOutcome.Yes;
        tokenHolder = ITokenHolder(_tokenHolderAddress);
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
            _tryPrice += (10 ** (decimals - granularity))
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

                    _executeDirectTrade(
                        order,
                        _tryOrder,
                        _matchedShares,
                        _tryPrice,
                        _outcome
                    );

                    _checkAndUpdateOrderStatus(order);
                    _checkAndUpdateOrderStatus(_tryOrder);
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

                _executeGeneratingTrade(
                    order,
                    _tryOrder,
                    _price,
                    _oppositePrice,
                    _outcome,
                    _oppositeOutcome,
                    _matchedShares
                );
                // also do -=rem_shares
                _checkAndUpdateOrderStatus(order);
                _checkAndUpdateOrderStatus(_tryOrder);
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
            _tryPrice -= (10 ** (decimals - granularity))
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

                    _executeDirectTrade(
                        _tryOrder,
                        order,
                        _matchedShares,
                        _tryPrice,
                        _outcome
                    );

                    _checkAndUpdateOrderStatus(order);
                    _checkAndUpdateOrderStatus(_tryOrder);
                }
            }
        }
    }

    function _executeDirectTrade(
        Order storage _buyOrder,
        Order storage _sellOrder,
        uint _matchedShares,
        uint _price,
        BetOutcome _outcome
    ) private {
        require(
            _buyOrder.user != _sellOrder.user,
            "Buyer and seller cannot be the same"
        );
        require(_buyOrder.isActive, "Buy order is not active");
        require(_sellOrder.isActive, "Sell order is not active");
        require(_matchedShares > 0, "Shares must be greater than 0");
        require(
            reservedShares[_outcome][_sellOrder.user] >= _matchedShares,
            "Insufficient shares"
        );

        tokenHolder.transferFromReserved(
            _buyOrder.user,
            _sellOrder.user,
            _matchedShares * _price
        );

        freeShares[_outcome][_buyOrder.user] += _matchedShares;
        reservedShares[_outcome][_sellOrder.user] -= _matchedShares;

        _buyOrder.remainingShares -= _matchedShares;
        _sellOrder.remainingShares -= _matchedShares;

        // TODO: emit event
    }

    function _executeGeneratingTrade(
        Order storage _buyOrder1,
        Order storage _buyOrder2,
        uint _price1,
        uint _price2,
        BetOutcome _betOutcome1,
        BetOutcome _betOutcome2,
        uint _matchedShares
    ) private {
        require(
            _buyOrder1.user != _buyOrder2.user,
            "Buyer and seller cannot be the same"
        );
        require(_buyOrder1.isActive, "Buy order is not active");
        require(_buyOrder2.isActive, "Sell order is not active");
        require(_matchedShares > 0, "Shares must be greater than 0");
        require(_price1 + _price2 == 10 ** decimals, "Prices must add up to 1");

        tokenHolder.transferFromReserved(
            _buyOrder1.user,
            address(this),
            _matchedShares * _price1
        );
        tokenHolder.transferFromReserved(
            _buyOrder2.user,
            address(this),
            _matchedShares * _price2
        );

        freeShares[_betOutcome1][_buyOrder1.user] += _matchedShares;
        freeShares[_betOutcome2][_buyOrder2.user] += _matchedShares;
        issuedShares += _matchedShares;

        _buyOrder1.remainingShares -= _matchedShares;
        _buyOrder2.remainingShares -= _matchedShares;
    }

    function _checkAndUpdateOrderStatus(Order storage _order) private {
        if (_order.remainingShares == 0) {
            _order.isActive = false;
            userActiveOrdersCount[_order.user]--;
        }
    }
}
