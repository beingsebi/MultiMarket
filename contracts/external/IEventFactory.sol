// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

interface IEventFactory {
    function createEvent(
        address owner,
        uint16 decimals,
        uint16 granularity,
        string memory _eventTitle,
        string memory _eventDescription,
        string memory _firstMarketTitle,
        string memory _firstMarketDescription
    ) external returns (address);
}
