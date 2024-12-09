// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./02_EventFactory.sol";

contract EventBetter is EventFactory {
    constructor(
        address _currencyToken,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    )
        EventFactory(
            _currencyToken,
            _decimals,
            _granularity,
            _eventCreationFee,
            _marketCreationFee
        )
    {}
}
