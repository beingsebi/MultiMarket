// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../event/Event.sol";

contract EventFactory {
    function createEvent(
        address owner,
        uint16 decimals,
        uint16 granularity,
        string memory _eventTitle,
        string memory _eventDescription,
        string memory _firstMarketTitle,
        string memory _firstMarketDescription
    ) external returns (address) {
        Event _event = new Event(
            owner,
            decimals,
            granularity,
            _eventTitle,
            _eventDescription,
            _firstMarketTitle,
            _firstMarketDescription
        );

        return address(_event);
    }
}
