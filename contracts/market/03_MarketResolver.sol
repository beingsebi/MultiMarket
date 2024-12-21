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

    // TODO test
    function resolveMarket(BetOutcome _winningOutcome) external onlyOwner {
        require(
            _winningOutcome == BetOutcome.Yes ||
                _winningOutcome == BetOutcome.No,
            "Invalid winning outcome"
        );

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

        // cancel all active orders
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
}
