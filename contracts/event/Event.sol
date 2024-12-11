// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../market/Market.sol";
import "../external/IMarketFactory.sol";

contract Event is Ownable {
    IMarketFactory internal marketFactory;

    // Decimals of the currency token
    // x / 10^decimals = x tokens
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;

    string public title;
    string public description;
    address[] public markets;

    constructor(
        address _owner,
        address _marketFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description
    ) Ownable(_owner) {
        marketFactory = IMarketFactory(_marketFactoryAddress);
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;
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
        address marketAddress = marketFactory.createMarket(
            address(this),
            decimals,
            granularity,
            _marketTitle,
            _marketDescription
        );

        if (marketAddress == address(0)) {
            return false;
        }

        markets.push(marketAddress);

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

    /**
     * @notice Retrieves details of a specific market.
     * @param _index The index of the market to retrieve.
     * @return The market title and description.
     */
    function getMarket(
        uint _index
    ) external view returns (string memory, string memory) {
        Market _market = Market(markets[_index]);
        return _market.getMarket();
    }

    function getMarketCount() external view returns (uint) {
        return markets.length;
    }
}
