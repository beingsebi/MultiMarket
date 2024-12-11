// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../market/Market.sol";

contract Event is Ownable {
    // Decimals of the currency token
    // x / 10^decimals = x tokens
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;

    string public title;
    string public description;
    address[] public markets;

    constructor(
        address owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description,
        string memory _firstMarketTitle,
        string memory _firstMarketDescription
    ) Ownable(owner) {
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;

        Market _market = new Market(
            _decimals,
            _granularity,
            _firstMarketTitle,
            _firstMarketDescription
        );

        markets.push(address(_market));
    }

    /**
     * @notice Adds a new market to an existing event.
     * @dev Only the event admin can add markets. Deducts the market creation fee from the sender's balance.
     * @param _marketTitle The title of the new market.
     * @param _marketDescription A description of the new market.
     */
    function addMarket(
        string memory _marketTitle,
        string memory _marketDescription
    ) external onlyOwner returns (bool) {
        Market _market = new Market(
            decimals,
            granularity,
            _marketTitle,
            _marketDescription
        );

        if (address(_market) == address(0)) {
            return false;
        }

        markets.push(address(_market));

        return true;
    }

    /**
     * @notice Retrieves details of a specific event and its markets.
     * @return The event title, description, and arrays of market titles and descriptions.
     */
    function getEvent()
        external
        view
        returns (string memory, string memory, string[] memory, string[] memory)
    {
        string[] memory _marketsTitles = new string[](markets.length);
        string[] memory _marketsDescriptions = new string[](markets.length);

        for (uint i = 0; i < markets.length; i++) {
            Market _market = Market(markets[i]);
            _marketsTitles[i] = _market.title();
            _marketsDescriptions[i] = _market.description();
        }

        return (title, description, _marketsTitles, _marketsDescriptions);
    }

    function getMarketCount() external view returns (uint) {
        return markets.length;
    }
}
