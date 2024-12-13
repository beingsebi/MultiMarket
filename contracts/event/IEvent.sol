// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../utils/OrderDefinitions.sol";

interface IEvent {
    /**
     * @notice Adds a new market to an existing event.
     * @dev Only the event admin can add markets.
     * @param _marketTitle The title of the new market.
     * @param _marketDescription A description of the new market.
     * @return A boolean indicating if the market was successfully added.
     */
    function addMarket(
        string memory _marketTitle,
        string memory _marketDescription
    ) external returns (bool);

    /**
     * @notice Retrieves details of a specific event and its markets.
     * @return title The event title.
     * @return description The event description.
     * @return marketTitles An array of market titles.
     * @return marketDescriptions An array of market descriptions.
     */
    function getEvent()
        external
        view
        returns (
            string memory title,
            string memory description,
            string[] memory marketTitles,
            string[] memory marketDescriptions
        );

    /**
     * @notice Retrieves details of a specific market.
     * @param _index The index of the market to retrieve.
     * @return The market title and description.
     */
    function getMarket(
        uint _index
    ) external view returns (string memory, string memory);

    /**
     * @notice Retrieves the number of markets in the event.
     * @return The number of markets.
     */
    function getMarketCount() external view returns (uint);

    function placeLimitBuyOrder(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _price,
        uint _shares
    ) external;

    function placeLimitSellOrder(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _price,
        uint _shares
    ) external;
}
