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

    event marketOrderFilled(
        address indexed user,
        BetOutcome indexed outcome,
        OrderSide indexed side,
        uint avgPrice,
        uint totalPrice,
        uint filledShares,
        uint unfilledShares
    );

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

    /**
     * @notice Returns the user's positions in the market.
     * @param user The user's address.
     * @return The user's positions in the market.
     * [0] => freeShares[Yes]
     * [1] => reservedShares[Yes]
     * [2] => freeShares[No]
     * [3] => reservedShares[No]
     */
    function getPositions(
        address user
    ) external view returns (uint, uint, uint, uint) {
        return (
            freeShares[BetOutcome.Yes][user],
            reservedShares[BetOutcome.Yes][user],
            freeShares[BetOutcome.No][user],
            reservedShares[BetOutcome.No][user]
        );
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
        BetOutcome _oppositeOutcome = oppositeBetOutcome[_outcome];

        for (
            uint _tryPrice = 0;
            _tryPrice <= _price && order.remainingShares > 0;
            _tryPrice += (10 ** (decimals - granularity))
        ) {
            //match buy order with sell order
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

            // match buy order with buy order of opposite outcome
            uint _oppositePrice = 10 ** decimals - _tryPrice;
            for (
                uint _tryIndexInOB = 0;
                _tryIndexInOB <
                orderBook[_oppositeOutcome][OrderSide.Buy][_oppositePrice]
                    .length &&
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

                    _checkAndUpdateOrderStatus(order);
                    _checkAndUpdateOrderStatus(_tryOrder);
                }
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
            "Buyer of yes and buyer of No cannot be the same"
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
        uint filledShares = 0;
        uint totalCost = 0;
        BetOutcome _oppositeOutcome = oppositeBetOutcome[_outcome];

        for (
            uint _tryPrice = 0;
            _tryPrice <= 10 ** decimals && _shares > 0;
            _tryPrice += 10 ** (decimals - granularity)
        ) {
            uint oppositePrice = 10 ** decimals - _tryPrice;
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

            //match with buy orders of opposite outcome
            for (
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
    ) external onlyOwner {
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
        } else {
            freeShares[_outcome][_user] -= _matchedShares;
            freeShares[_outcome][_order.user] += _matchedShares;

            tokenHolder.transferFromReserved(
                _order.user,
                _user,
                _matchedShares * _price
            );
        } //TODO Check if this is correct

        _order.remainingShares -= _matchedShares;
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
        _checkAndUpdateOrderStatus(_order);
    }
}
