// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

interface IEventFactory {
    function createEvent(
        address _owner,
        address _marketFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        string memory _eventTitle,
        string memory _eventDescription
    ) external returns (address);
}
