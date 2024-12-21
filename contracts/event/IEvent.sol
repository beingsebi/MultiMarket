// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../utils/OrderDefinitions.sol";

interface IEvent {
    function addMarket(
        string memory _marketTitle,
        string memory _marketDescription
    ) external returns (address);

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

    function title() external view returns (string memory);

    function description() external view returns (string memory);

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

    function getPositions(
        address user
    )
        external
        view
        returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory);

    function getAllMarkets()
        external
        view
        returns (string[] memory, string[] memory);

    function placeMarketBuyOrderByShares(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _shares
    ) external;

    function placeMarketSellOrderByShares(
        address user,
        uint _marketIndex,
        BetOutcome _betOutcome,
        uint _shares
    ) external;

    function resolveMarket(
        uint _marketIndex,
        BetOutcome _winningOutcome
    ) external;

    function getActiveOrders(
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderSide _orderSide,
        address _user
    ) external view returns (Order[] memory);

    function cancelOrder(
        uint _marketIndex,
        BetOutcome _outcome,
        OrderSide _side,
        uint _price,
        uint _orderIndex,
        address _user
    ) external;

    function getCurrentPrice(
        uint _marketIndex,
        BetOutcome _betOutcome
    ) external view returns (uint, uint);
}
