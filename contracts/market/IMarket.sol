// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "../utils/OrderDefinitions.sol";

interface IMarket {
    /**
     * @notice Returns the market's title and description.
     * @return The market's title and description.
     */
    function getMarket() external view returns (string memory, string memory);

    function placeLimitBuyOrder(
        address user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external;

    function placeLimitSellOrder(
        address user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external;

    function getPositions(
        address user
    ) external view returns (uint, uint, uint, uint);
}
