// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./01_LimitOrders.sol";

contract MarketOrders is LimitOrders {
    constructor(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description,
        address _tokenHolderAddress
    )
        LimitOrders(
            _owner,
            _decimals,
            _granularity,
            _title,
            _description,
            _tokenHolderAddress
        )
    {}

    /*
     * @notice Places a market buy order of _shares shares for _outcome.
     * @param user The address of the user placing the order.
     * @param _outcome The outcome of the bet.
     * @param _shares The number of shares to buy.
     * @return filledShares The number of shares filled.
     * @return totalCost The total cost of the filled shares.
     * @return remainingShares The number of shares that were not filled.
     * @dev The function will try to fill the order at the best available price.
     */
    function placeMarketBuyOrderByShares(
        address user,
        BetOutcome _outcome,
        uint _shares
    ) external onlyOwner returns (uint, uint, uint) {
        require(isResolved == false, "Market is resolved");

        uint filledShares = 0;
        uint totalCost = 0;
        BetOutcome _oppositeOutcome = oppositeBetOutcome[_outcome];

        for (
            uint _tryPrice = 0;
            _tryPrice <= 10 ** decimals && _shares > 0;
            _tryPrice += 10 ** (decimals - granularity)
        ) {
            //match with sell orders
            for (
                uint _tryIndexInOB = 0;
                _tryIndexInOB <
                orderBook[_outcome][OrderSide.Sell][_tryPrice].length &&
                    _shares > 0;
                _tryIndexInOB++
            ) {
                if (
                    orderBook[_outcome][OrderSide.Sell][_tryPrice][
                        _tryIndexInOB
                    ].isActive
                ) {
                    Order storage _tryOrder = orderBook[_outcome][
                        OrderSide.Sell
                    ][_tryPrice][_tryIndexInOB];

                    uint _matchedShares = _shares < _tryOrder.remainingShares
                        ? _shares
                        : _tryOrder.remainingShares;

                    _executeDirectMarketOrder(
                        _tryOrder,
                        OrderSide.Buy,
                        user,
                        _outcome,
                        _matchedShares,
                        _tryPrice
                    );

                    filledShares += _matchedShares;
                    _shares -= _matchedShares;

                    totalCost += _matchedShares * _tryPrice;
                }
            }

            uint oppositePrice = 10 ** decimals - _tryPrice;
            for (
                //match with buy orders of opposite outcome
                uint _tryIndexInOB = 0;
                _tryIndexInOB <
                orderBook[_oppositeOutcome][OrderSide.Buy][oppositePrice]
                    .length &&
                    _shares > 0;
                _tryIndexInOB++
            ) {
                if (
                    orderBook[_oppositeOutcome][OrderSide.Buy][oppositePrice][
                        _tryIndexInOB
                    ].isActive
                ) {
                    Order storage _tryOrder = orderBook[_oppositeOutcome][
                        OrderSide.Buy
                    ][oppositePrice][_tryIndexInOB];

                    uint _matchedShares = _shares < _tryOrder.remainingShares
                        ? _shares
                        : _tryOrder.remainingShares;

                    _executeGeneratingMarketOrder(
                        _tryOrder,
                        user,
                        _outcome,
                        _oppositeOutcome,
                        _matchedShares,
                        _tryPrice,
                        oppositePrice
                    );

                    filledShares += _matchedShares;
                    _shares -= _matchedShares;

                    totalCost += _matchedShares * _tryPrice;
                }
            }
        }
        return (filledShares, totalCost, _shares);
    }

    function placeMarketSellOrderByShares(
        address user,
        BetOutcome _outcome,
        uint _shares
    ) external onlyOwner returns (uint, uint, uint) {
        // require(isResolved == false, "Market is resolved");
        require(
            freeShares[_outcome][user] >= _shares,
            "Insufficient free shares"
        );

        uint filledShares = 0;
        uint totalPrice = 0;

        for (
            uint _tryPrice = 10 ** decimals;
            _tryPrice >= 0 && _shares > 0;
            _tryPrice -= 10 ** (decimals - granularity)
        ) {
            for (
                uint _tryIndexInOB = 0;
                _tryIndexInOB <
                orderBook[_outcome][OrderSide.Buy][_tryPrice].length &&
                    _shares > 0;
                _tryIndexInOB++
            ) {
                if (
                    orderBook[_outcome][OrderSide.Buy][_tryPrice][_tryIndexInOB]
                        .isActive
                ) {
                    Order storage _tryOrder = orderBook[_outcome][
                        OrderSide.Buy
                    ][_tryPrice][_tryIndexInOB];

                    uint _matchedShares = _shares < _tryOrder.remainingShares
                        ? _shares
                        : _tryOrder.remainingShares;

                    _executeDirectMarketOrder(
                        _tryOrder,
                        OrderSide.Sell,
                        user,
                        _outcome,
                        _matchedShares,
                        _tryPrice
                    );

                    filledShares += _matchedShares;
                    _shares -= _matchedShares;

                    totalPrice += _matchedShares * _tryPrice;
                }
            }
        }
        return (filledShares, totalPrice, _shares);
    }

    function _executeDirectMarketOrder(
        Order storage _order, // the order that got matched with _user's market order
        OrderSide _side, // what is _user doing
        address _user,
        BetOutcome _outcome,
        uint _matchedShares,
        uint _price
    ) private {
        require(
            _order.remainingShares >= _matchedShares,
            "Insufficient shares"
        );

        if (_side == OrderSide.Buy) {
            freeShares[_outcome][_user] += _matchedShares;
            reservedShares[_outcome][_order.user] -= _matchedShares;

            tokenHolder.transferFromFree(
                _user,
                _order.user,
                _matchedShares * _price
            );

            emit DirectTrade(
                _user,
                _order.user,
                _outcome,
                _price,
                _matchedShares
            );
        } else {
            freeShares[_outcome][_user] -= _matchedShares;
            freeShares[_outcome][_order.user] += _matchedShares;

            tokenHolder.transferFromReserved(
                _order.user,
                _user,
                _matchedShares * _price
            );

            emit DirectTrade(
                _order.user,
                _user,
                _outcome,
                _price,
                _matchedShares
            );
        }

        _order.remainingShares -= _matchedShares;
        _order.currentTotalPrice += _matchedShares * _price;

        _checkAndUpdateOrderStatus(_order);
    }

    function _executeGeneratingMarketOrder(
        Order storage _order, // the order that got matched with _user's market order
        address _user,
        BetOutcome _outcomeUser,
        BetOutcome _outcomeOrder,
        uint _matchedShares,
        uint _priceUser,
        uint _priceOrder
    ) private {
        require(
            _order.user != _user,
            "Buyer of yes and buyer of No cannot be the same"
        );
        require(_order.isActive, "Limit order is not active");
        require(_matchedShares > 0, "Shares must be greater than 0");
        require(
            _priceUser + _priceOrder == 10 ** decimals,
            "Prices must add up to 1"
        );

        tokenHolder.transferFromFree(
            _user,
            address(this),
            _matchedShares * _priceUser
        );
        tokenHolder.transferFromReserved(
            _order.user,
            address(this),
            _matchedShares * _priceOrder
        );

        freeShares[_outcomeUser][_user] += _matchedShares;
        freeShares[_outcomeOrder][_order.user] += _matchedShares;
        issuedShares += _matchedShares;

        _order.remainingShares -= _matchedShares;
        _order.currentTotalPrice += _matchedShares * _priceOrder;

        emit GeneratingTrade(
            _user,
            _outcomeUser,
            _priceUser,
            _order.user,
            _matchedShares
        );

        _checkAndUpdateOrderStatus(_order);
    }

    function getActiveOrders(
        BetOutcome _outcome,
        OrderSide _side,
        address _user
    ) external view returns (OrderDto[] memory) {
        uint activeOrderCount = 0;

        for (
            uint _price = 0;
            _price <= 10 ** decimals;
            _price += 10 ** (decimals - granularity)
        ) {
            for (
                uint _index = 0;
                _index < orderBook[_outcome][_side][_price].length;
                _index++
            ) {
                if (
                    orderBook[_outcome][_side][_price][_index].isActive &&
                    orderBook[_outcome][_side][_price][_index].user == _user
                ) {
                    activeOrderCount++;
                }
            }
        }

        OrderDto[] memory _orders = new OrderDto[](activeOrderCount);
        uint counter = 0;

        for (
            uint _price = 0;
            _price <= 10 ** decimals;
            _price += 10 ** (decimals - granularity)
        ) {
            for (
                uint _index = 0;
                _index < orderBook[_outcome][_side][_price].length;
                _index++
            ) {
                if (
                    orderBook[_outcome][_side][_price][_index].isActive &&
                    orderBook[_outcome][_side][_price][_index].user == _user
                ) {
                    Order memory order = orderBook[_outcome][_side][_price][
                        _index
                    ];
                    _orders[counter].initialShares = order.initialShares;
                    _orders[counter].remainingShares = order.remainingShares;
                    _orders[counter].timestamp = order.timestamp;
                    _orders[counter].totalCostOfFilledShares = order
                        .currentTotalPrice;
                    _orders[counter].price = _price;

                    counter++;
                }
            }
        }

        return _orders;
    }
}
