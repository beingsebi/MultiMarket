// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./02_MarketCreator.sol";

contract OrderPlacer is MarketCreator {
    constructor(
        address _currencyToken,
        address _eventFactoryAddress,
        address _marketFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    )
        MarketCreator(
            _currencyToken,
            _eventFactoryAddress,
            _marketFactoryAddress,
            _decimals,
            _granularity,
            _eventCreationFee,
            _marketCreationFee
        )
    {}

    /**
     * @notice Retrieves the positions of a user in a specific event.
     * @param _eventIndex The index of the event to retrieve.
     * @param _user The address of the user.
     * @return The user's positions in the event:
     * free YES shares, reserved YES shares, free NO shares, reserved NO shares.
     */
    function getPositions(
        uint _eventIndex,
        address _user
    )
        external
        view
        returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory)
    {
        require(_eventIndex < events.length, "Invalid event index");
        return IEvent(events[_eventIndex]).getPositions(_user);
    }

    function placeLimitOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderSide _orderSide,
        uint _price,
        uint _shares
    ) external {
        require(
            _betOutcome == BetOutcome.Yes || _betOutcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        require(
            _orderSide == OrderSide.Buy || _orderSide == OrderSide.Sell,
            "Invalid order side"
        );
        require(_eventIndex < events.length, "Invalid event index");
        require(
            _price >= 0 && _price <= 10 ** decimals,
            "Price must be between 0 and 1 (* 10^decimals)"
        );
        require(
            _price % (10 ** (decimals - granularity)) == 0,
            "Price must be a multiple of 10^(decimals - granularity)"
        );
        require(_shares > 0, "Shares must be greater than 0");

        IEvent _event = IEvent(events[_eventIndex]);

        require(_marketIndex < _event.getMarketCount(), "Invalid market index");

        if (_orderSide == OrderSide.Buy) {
            require(
                freeBalances[msg.sender] >= _price * _shares,
                "Insufficient free funds"
            );
            freeBalances[msg.sender] -= _price * _shares;
            reservedBalances[msg.sender] += _price * _shares;

            _event.placeLimitBuyOrder(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _price,
                _shares
            );
        } else {
            _event.placeLimitSellOrder(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _price,
                _shares
            );
        }
    }

    function placeMarketOrderByShares(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderSide _orderSide,
        uint _shares
    ) external {
        require(
            _betOutcome == BetOutcome.Yes || _betOutcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        require(
            _orderSide == OrderSide.Buy || _orderSide == OrderSide.Sell,
            "Invalid order side"
        );
        require(_eventIndex < events.length, "Invalid event index");
        require(_shares > 0, "Shares must be greater than 0");

        IEvent _event = IEvent(events[_eventIndex]);

        require(_marketIndex < _event.getMarketCount(), "Invalid market index");

        if (_orderSide == OrderSide.Buy) {
            _event.placeMarketBuyOrderByShares(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _shares
            );
        } else {
            _event.placeMarketSellOrderByShares(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _shares
            );
        }
    }
}
