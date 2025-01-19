// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../utils/OrderDefinitions.sol";

interface IMarket {
    /**
     * @notice Returns the market's title and description.
     * @return The market's title and description.
     */
    function getMarket()
        external
        view
        returns (string memory, string memory, bool);

    function placeLimitBuyOrder(
        address _user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external;

    function placeLimitSellOrder(
        address _user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external;

    function getPositions(
        address _user
    ) external view returns (uint, uint, uint, uint);

    function placeMarketBuyOrderByShares(
        address _user,
        BetOutcome _outcome,
        uint _shares
    ) external returns (uint, uint, uint);

    function placeMarketSellOrderByShares(
        address _user,
        BetOutcome _outcome,
        uint _shares
    ) external returns (uint, uint, uint);

    function resolveMarket(BetOutcome _winningOutcome) external;

    function getActiveOrders(
        BetOutcome _outcome,
        OrderSide _side,
        address _user
    ) external view returns (Order[] memory);

    function cancelOrder(
        BetOutcome _outcome,
        OrderSide _side,
        uint _price,
        uint _orderIndex,
        address _user
    ) external;

    function getCurrentPrice(
        BetOutcome _outcome
    ) external view returns (uint, uint);
}
