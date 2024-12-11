// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Market is Ownable {
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;

    string public title;
    string public description;
    uint public issuedShares;

    //orderbook

    constructor(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description
    ) Ownable(_owner) {
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;
    }

    /**
     * @notice Returns the market's title and description.
     * @return The market's title and description.
     */
    function getMarket() external view returns (string memory, string memory) {
        return (title, description);
    }
}
