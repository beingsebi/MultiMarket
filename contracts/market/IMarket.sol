// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

interface IMarket {
    /**
     * @notice Returns the market's title and description.
     * @return The market's title and description.
     */
    function getMarket() external view returns (string memory, string memory);
}
