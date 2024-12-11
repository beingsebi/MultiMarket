// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

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
     * @notice Retrieves the number of markets in the event.
     * @return The number of markets.
     */
    function getMarketCount() external view returns (uint);
}
