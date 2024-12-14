// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

interface IMarketFactory {
    function createMarket(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _marketTitle,
        string memory _marketDescription,
        address _tokenHolderAddress
    ) external returns (address);
}
