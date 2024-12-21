// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../event/Event.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// TODO: make it ownable, and after deployment, transfer ownership to the main contract
contract EventFactory is Ownable {
    constructor() Ownable(msg.sender) {}

    function createEvent(
        address _owner,
        address _marketFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        string memory _eventTitle,
        string memory _eventDescription
    ) external onlyOwner returns (address) {
        return
            address(
                new Event(
                    _owner,
                    _marketFactoryAddress,
                    _decimals,
                    _granularity,
                    _eventTitle,
                    _eventDescription
                )
            );
    }
}
