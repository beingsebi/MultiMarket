// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./03_OrderMatcher.sol";

contract OrderPlacer is OrderMatcher {
    event LimitOrderPlaced(
        address indexed user,
        uint indexed eventIndex,
        uint marketIndex,
        uint orderIdentifierIndex
    );

    constructor(
        address _currencyToken,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    )
        OrderMatcher(
            _currencyToken,
            _decimals,
            _granularity,
            _eventCreationFee,
            _marketCreationFee
        )
    {}

    function placeOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderType _orderType,
        uint _price,
        uint _shares
    ) external {
        require(_eventIndex < events.length, "Invalid event index");
        require(
            _marketIndex < events[_eventIndex].markets.length,
            "Invalid market index"
        );
        require(
            _price > 0 && _price < 10 ** decimals,
            "Price must be between 0 and 1 (* 10^decimals)"
        );
        require(
            _price % (10 ** granularity) == 0,
            "Price must be a multiple of 10^granularity"
        );

        require(
            _betOutcome == BetOutcome.Yes || _betOutcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        require(
            _orderType == OrderType.Buy || _orderType == OrderType.Sell,
            "Invalid order type"
        );
        require(_shares > 0, "Shares must be greater than 0");

        if (_orderType == OrderType.Buy) {
            _placeLimitBuyOrder(
                _eventIndex,
                _marketIndex,
                _betOutcome,
                _orderType,
                _price,
                _shares
            );
        } else if (_orderType == OrderType.Sell) {
            _placeLimitSellOrder(
                _eventIndex,
                _marketIndex,
                _betOutcome,
                _orderType,
                _price,
                _shares
            );
        }

        emit LimitOrderPlaced(
            msg.sender,
            _eventIndex,
            _marketIndex,
            events[_eventIndex]
                .markets[_marketIndex]
                .orderBook
                .orderIdentifiers
                .length - 1
        );

        uint _indexInOB = events[_eventIndex]
        .markets[_marketIndex]
        .orderBook
        .ob[_betOutcome][_orderType][_price].length - 1;

        if (_orderType == OrderType.Buy) {
            _tryMatchBuyOrder(
                _eventIndex,
                _marketIndex,
                _betOutcome,
                _price,
                _indexInOB,
                _shares
            );
        } else if (_orderType == OrderType.Sell) {
            // _tryMatchSellOrder(
            //     _eventIndex,
            //     _marketIndex,
            //     _betOutcome,
            //     _price,
            //     _indexInOB,
            //     _shares
            // );
        }
    }

    function _placeLimitBuyOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderType _orderType,
        uint _price,
        uint _shares
    ) private {
        require(
            balances[msg.sender] - reservedBalances[msg.sender] >=
                _price * _shares,
            "Insufficient balance"
        );

        Order memory order = Order(msg.sender, _shares, block.timestamp, true);

        OrderIdentifier memory orderIdentifier = OrderIdentifier(
            _eventIndex,
            _marketIndex,
            _betOutcome,
            _orderType,
            _price,
            events[_eventIndex]
                .markets[_marketIndex]
                .orderBook
                .orderIdentifiers
                .length
        );

        events[_eventIndex]
            .markets[_marketIndex]
            .orderBook
            .orderIdentifiers
            .push(orderIdentifier);

        events[_eventIndex]
        .markets[_marketIndex]
        .orderBook
        .ob[_betOutcome][_orderType][_price].push(order);

        events[_eventIndex]
            .markets[_marketIndex]
            .orderBook
            .userActiveOrdersCount[msg.sender]++;

        reservedBalances[msg.sender] += _price * _shares;
    }

    function _placeLimitSellOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderType _orderType,
        uint _price,
        uint _shares
    ) private {
        require(
            events[_eventIndex].markets[_marketIndex].shares[_betOutcome][
                msg.sender
            ] -
                events[_eventIndex].markets[_marketIndex].reservedShares[
                    _betOutcome
                ][msg.sender] >=
                _shares,
            "Insufficient shares"
        );

        Order memory order = Order(msg.sender, _shares, block.timestamp, true);

        OrderIdentifier memory orderIdentifier = OrderIdentifier(
            _eventIndex,
            _marketIndex,
            _betOutcome,
            _orderType,
            _price,
            events[_eventIndex]
                .markets[_marketIndex]
                .orderBook
                .orderIdentifiers
                .length
        );

        events[_eventIndex]
            .markets[_marketIndex]
            .orderBook
            .orderIdentifiers
            .push(orderIdentifier);

        events[_eventIndex]
        .markets[_marketIndex]
        .orderBook
        .ob[_betOutcome][_orderType][_price].push(order);

        events[_eventIndex]
            .markets[_marketIndex]
            .orderBook
            .userActiveOrdersCount[msg.sender]++;

        events[_eventIndex].markets[_marketIndex].reservedShares[_betOutcome][
                msg.sender
            ] += _shares;
    }

    function _tryMatchBuyOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _price,
        uint _indexInOB,
        uint _shares
    ) private {
        // match buy order with sell order
        for (
            uint _tryPrice = 1;
            _shares > 0 && _tryPrice < _price;
            _tryPrice++
        ) {
            for (
                uint _tryIndexInOb = 0;
                _shares > 0 &&
                    _tryIndexInOb <
                    events[_eventIndex]
                    .markets[_marketIndex]
                    .orderBook
                    .ob[_betOutcome][OrderType.Sell][_tryPrice].length;
                _tryIndexInOb++
            ) {
                Order storage order = events[_eventIndex]
                    .markets[_marketIndex]
                    .orderBook
                    .ob[_betOutcome][OrderType.Sell][_tryPrice][_tryIndexInOb];

                if (order.isActive) {
                    uint _matchedShares = _shares < order.shares
                        ? _shares
                        : order.shares;

                    _executeDirectTrade(
                        _eventIndex,
                        _marketIndex,
                        _betOutcome,
                        _price,
                        _indexInOB,
                        _tryPrice,
                        _tryIndexInOb,
                        _matchedShares,
                        _tryPrice
                    );

                    _shares -= _matchedShares;
                }
            }
        }

        //match buy order with buy order of opposite outcome
        BetOutcome _oppositeBetOutcome = oppositeBetOutcome[_betOutcome];
        uint _oppositePrice = 10 ** decimals - _price;

        for (
            uint _tryIndexInOb = 0;
            _shares > 0 &&
                _tryIndexInOb <
                events[_eventIndex]
                .markets[_marketIndex]
                .orderBook
                .ob[_oppositeBetOutcome][OrderType.Sell][_oppositePrice].length;
            _tryIndexInOb++
        ) {
            Order storage order = events[_eventIndex]
                .markets[_marketIndex]
                .orderBook
                .ob[_oppositeBetOutcome][OrderType.Sell][_oppositePrice][
                    _tryIndexInOb
                ];

            if (order.isActive) {
                uint _matchedShares = _shares < order.shares
                    ? _shares
                    : order.shares;

                _executeGeneratingSharesTrade(
                    _eventIndex,
                    _marketIndex,
                    _betOutcome,
                    _price,
                    _indexInOB,
                    _oppositeBetOutcome,
                    _oppositePrice,
                    _tryIndexInOb,
                    _matchedShares
                );

                _shares -= _matchedShares;
            }
        }
    }
}
