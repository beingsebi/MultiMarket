// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./02_MarketOrders.sol";

contract Market is MarketOrders {
    constructor(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description,
        address _tokenHolderAddress
    )
        MarketOrders(
            _owner,
            _decimals,
            _granularity,
            _title,
            _description,
            _tokenHolderAddress
        )
    {}

    function resolveMarket(BetOutcome _winningOutcome) external onlyOwner {
        require(
            _winningOutcome == BetOutcome.Yes ||
                _winningOutcome == BetOutcome.No,
            "Invalid winning outcome"
        );

        require(!isResolved, "Market already resolved");

        isResolved = true;

        Order memory order = Order({
            user: address(this),
            initialShares: issuedShares,
            remainingShares: issuedShares,
            timestamp: block.timestamp,
            isActive: true,
            currentTotalPrice: 0,
            index: orderBook[_winningOutcome][OrderSide.Buy][10 ** decimals]
                .length
        });

        orderBook[_winningOutcome][OrderSide.Buy][10 ** decimals].push(order);
        userActiveOrdersCount[address(this)]++;

        for (
            uint _price = 0;
            _price <= 10 ** decimals;
            _price += 10 ** granularity
        ) {
            for (
                uint _index = 0;
                _index <
                orderBook[_winningOutcome][OrderSide.Sell][_price].length;
                _index++
            ) {
                {
                    cancelOrder(
                        _winningOutcome,
                        OrderSide.Sell,
                        _price,
                        _index,
                        address(0)
                    );
                }
            }
        }
    }

    function getCurrentPrice(
        BetOutcome _outcome
    ) external view returns (uint, uint) {
        require(
            _outcome == BetOutcome.Yes || _outcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        return (_getCurrentBuyPrice(_outcome), _getCurrentSellPrice(_outcome));
    }

    function _getCurrentBuyPrice(
        BetOutcome _outcome
    ) internal view returns (uint) {
        uint step = 10 ** (decimals - granularity);
        uint _price = 10 ** decimals;

        while (_price >= step) {
            for (
                uint _index = 0;
                _index < orderBook[_outcome][OrderSide.Buy][_price].length;
                _index++
            ) {
                if (
                    orderBook[_outcome][OrderSide.Buy][_price][_index].isActive
                ) {
                    return _price;
                }
            }
            _price -= step;
        }

        return 0;
    }

    function _getCurrentSellPrice(
        BetOutcome _outcome
    ) internal view returns (uint) {
        uint step = 10 ** (decimals - granularity);
        uint _price = 0;

        while (_price <= 10 ** decimals) {
            for (
                uint _index = 0;
                _index < orderBook[_outcome][OrderSide.Sell][_price].length;
                _index++
            ) {
                if (
                    orderBook[_outcome][OrderSide.Sell][_price][_index].isActive
                ) {
                    return _price;
                }
            }
            _price += step;
        }

        return 10 ** decimals;
    }
}
