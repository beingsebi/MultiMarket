// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../market/IMarket.sol";
import "../external/IMarketFactory.sol";
import "../utils/OrderDefinitions.sol";

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

    function addMarket(
        string memory _marketTitle,
        string memory _marketDescription
    ) external onlyOwner returns (address) {
        address marketAddress = marketFactory.createMarket(
            address(this),
            decimals,
            granularity,
            _marketTitle,
            _marketDescription
        );

        if (marketAddress == address(0)) {
            return address(0);
        }

        markets.push(marketAddress);

        return marketAddress;
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
            IMarket _market = IMarket(markets[i]);
            (_marketsTitles[i], _marketsDescriptions[i]) = _market.getMarket();
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
        IMarket _market = IMarket(markets[_index]);
        return _market.getMarket();
    }

    /**
     * @notice Retrieves the number of markets in the event.
     * @return The number of markets.
     */
    function getMarketCount() external view returns (uint) {
        return markets.length;
    }

    function placeLimitBuyOrder(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _price,
        uint _shares
    ) external {
        require(_marketIndex < markets.length, "Invalid market index");

        IMarket _market = IMarket(markets[_marketIndex]);

        _market.placeLimitBuyOrder(user, _betOutcome, _price, _shares);
    }

    function placeLimitSellOrder(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _price,
        uint _shares
    ) external {
        require(_marketIndex < markets.length, "Invalid market index");

        IMarket _market = IMarket(markets[_marketIndex]);

        return _market.placeLimitSellOrder(user, _betOutcome, _price, _shares);
    }
}
