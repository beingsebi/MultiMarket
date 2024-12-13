// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/OrderDefinitions.sol";

contract Market is Ownable {
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;

    string public title;
    string public description;
    uint public issuedShares;

    // [Yes/No][Buy/Sell][Price][OrderIndex]
    mapping(BetOutcome => mapping(OrderSide => mapping(uint => Order[]))) orderBook;
    mapping(address => uint) userActiveOrdersCount;

    // shares = free + reserved
    mapping(BetOutcome => mapping(address => uint)) freeShares;
    mapping(BetOutcome => mapping(address => uint)) reservedShares;

    constructor(
        address _owner,
        uint16 _decimals,
        uint16 _granularity,
        string memory _title,
        string memory _description
    ) Ownable(_owner) {
        decimals = _decimals;
        granularity = _granularity;
        title = _title;
        description = _description;
    }

    /**
     * @notice Returns the market's title and description.
     * @return The market's title and description.
     */
    function getMarket() external view returns (string memory, string memory) {
        return (title, description);
    }

    function placeLimitBuyOrder(
        address user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external onlyOwner returns (bool) {
        Order memory order = Order({
            user: user,
            initialShares: _shares,
            remainingShares: _shares,
            timestamp: block.timestamp,
            isActive: true
        });

        orderBook[_outcome][OrderSide.Buy][_price].push(order);
        userActiveOrdersCount[user]++;

        return true;
    }

    function placeLimitSellOrder(
        address user,
        BetOutcome _outcome,
        uint _price,
        uint _shares
    ) external onlyOwner returns (bool) {
        require(
            freeShares[_outcome][user] >= _shares,
            "Insufficient free shares"
        );

        Order memory order = Order({
            user: user,
            initialShares: _shares,
            remainingShares: _shares,
            timestamp: block.timestamp,
            isActive: true
        });

        freeShares[_outcome][user] -= _shares;
        reservedShares[_outcome][user] += _shares;

        orderBook[_outcome][OrderSide.Sell][_price].push(order);

        return true;
    }
}
