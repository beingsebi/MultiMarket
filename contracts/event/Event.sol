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
            _marketDescription,
            msg.sender
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

    /*
     * @notice Retrieves the positions of a user in all markets of the event.
     * @param user The address of the user.
     * @return An array of free YES shares for each market.
     * @return An array of reserved YES shares for each market.
     * @return An array of free NO shares for each market.
     * @return An array of reserved NO shares for each market.
     * @dev The arrays are ordered by market index.
     */
    function getPositions(
        address user
    )
        external
        view
        returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory)
    {
        uint[] memory _freeSharesYes = new uint[](markets.length);
        uint[] memory _reservedSharesYes = new uint[](markets.length);
        uint[] memory _freeSharesNo = new uint[](markets.length);
        uint[] memory _reservedSharesNo = new uint[](markets.length);

        for (uint i = 0; i < markets.length; i++) {
            IMarket _market = IMarket(markets[i]);
            (
                _freeSharesYes[i],
                _reservedSharesYes[i],
                _freeSharesNo[i],
                _reservedSharesNo[i]
            ) = _market.getPositions(user);
        }

        return (
            _freeSharesYes,
            _reservedSharesYes,
            _freeSharesNo,
            _reservedSharesNo
        );
    }

    function placeLimitBuyOrder(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _price,
        uint _shares
    ) external onlyOwner {
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
    ) external onlyOwner {
        require(_marketIndex < markets.length, "Invalid market index");

        IMarket _market = IMarket(markets[_marketIndex]);

        _market.placeLimitSellOrder(user, _betOutcome, _price, _shares);
    }

    function getAllMarkets()
        external
        view
        returns (string[] memory, string[] memory)
    {
        string[] memory _marketsTitles = new string[](markets.length);
        string[] memory _marketsDescriptions = new string[](markets.length);

        for (uint i = 0; i < markets.length; i++) {
            (_marketsTitles[i], _marketsDescriptions[i]) = IMarket(markets[i])
                .getMarket();
        }

        return (_marketsTitles, _marketsDescriptions);
    }

    function placeMarketBuyOrderByShares(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _shares
    ) external onlyOwner {
        IMarket _market = IMarket(markets[_marketIndex]);
        _market.placeMarketBuyOrderByShares(user, _betOutcome, _shares);
    }

    function placeMarketSellOrderByShares(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _shares
    ) external onlyOwner {
        IMarket _market = IMarket(markets[_marketIndex]);
        _market.placeMarketSellOrderByShares(user, _betOutcome, _shares);
    }
}
