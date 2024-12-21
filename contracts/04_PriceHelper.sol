// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./03_OrderPlacer.sol";

contract PriceHelper is OrderPlacer {
    constructor(
        address _currencyToken,
        address _eventFactoryAddress,
        address _marketFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    )
        OrderPlacer(
            _currencyToken,
            _eventFactoryAddress,
            _marketFactoryAddress,
            _decimals,
            _granularity,
            _eventCreationFee,
            _marketCreationFee
        )
    {}

    function getCurrentPrice(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome
    ) external view returns (uint, uint) {
        require(_eventIndex < events.length, "Invalid event index");
        IEvent _event = IEvent(events[_eventIndex]);
        return _event.getCurrentPrice(_marketIndex, _betOutcome);
    }
}
