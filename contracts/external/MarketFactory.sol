// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../market/03_MarketResolver.sol";

// TODO: make it ownable, and after deployment, transfer ownership to the main contract
contract MarketFactory {
    function createMarket(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _marketTitle,
        string memory _marketDescription,
        address _tokenHolderAddress
    ) external returns (address) {
        return
            address(
                new Market(
                    _owner,
                    _decimals,
                    _granularity,
                    _marketTitle,
                    _marketDescription,
                    _tokenHolderAddress
                )
            );
    }
}
