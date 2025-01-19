// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./02_MarketCreator.sol";

contract OrderPlacer is MarketCreator {
    event LimitOrderPlaced(
        address indexed user,
        uint indexed eventIndex,
        uint indexed marketIndex,
        BetOutcome betOutcome,
        OrderSide orderSide,
        uint price,
        uint shares
    );

    event MarketOrderPlaced(
        address indexed user,
        uint indexed eventIndex,
        uint indexed marketIndex,
        BetOutcome betOutcome,
        OrderSide orderSide,
        uint filledShares,
        uint totalCostOfFilledShares,
        uint unfilledShares
    );

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

        emit LimitOrderPlaced(
            msg.sender,
            _eventIndex,
            _marketIndex,
            _betOutcome,
            _orderSide,
            _price,
            _shares
        );
    }

    function placeMarketOrderByShares(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderSide _orderSide,
        uint _shares
    ) external returns (uint, uint, uint) {
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

        uint filled;
        uint totalCost;
        uint unfilled;

        if (_orderSide == OrderSide.Buy) {
            (filled, totalCost, unfilled) = _event.placeMarketBuyOrderByShares(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _shares
            );
        } else {
            (filled, totalCost, unfilled) = _event.placeMarketSellOrderByShares(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _shares
            );
        }
        emit MarketOrderPlaced(
            msg.sender,
            _eventIndex,
            _marketIndex,
            _betOutcome,
            _orderSide,
            filled,
            totalCost,
            unfilled
        );

        return (filled, totalCost, unfilled);
    }

    function getActiveOrders(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderSide _orderSide,
        address _user
    ) external view returns (OrderDto[] memory) {
        require(
            _betOutcome == BetOutcome.Yes || _betOutcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        require(
            _orderSide == OrderSide.Buy || _orderSide == OrderSide.Sell,
            "Invalid order side"
        );
        require(_eventIndex < events.length, "Invalid event index");

        IEvent _event = IEvent(events[_eventIndex]);

        require(_marketIndex < _event.getMarketCount(), "Invalid market index");

        return
            _event.getActiveOrders(
                _marketIndex,
                _betOutcome,
                _orderSide,
                _user
            );
    }

    function cancelOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _outcome,
        OrderSide _side,
        uint _price,
        uint _orderIndex
    ) external {
        require(
            _outcome == BetOutcome.Yes || _outcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        require(
            _side == OrderSide.Buy || _side == OrderSide.Sell,
            "Invalid order side"
        );
        require(_eventIndex < events.length, "Invalid event index");

        IEvent _event = IEvent(events[_eventIndex]);

        _event.cancelOrder(
            _marketIndex,
            _outcome,
            _side,
            _price,
            _orderIndex,
            msg.sender
        );
    }
}
