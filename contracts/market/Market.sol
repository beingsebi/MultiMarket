// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

contract Market {
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;

    string public title;
    string public description;
    uint public issuedShares;

    //orderbook

    constructor(
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description
    ) {
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;
    }
}
