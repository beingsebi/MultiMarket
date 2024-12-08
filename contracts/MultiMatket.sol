// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Utils.sol";

address constant USDC = 0x1291070C5f838DCCDddc56312893d3EfE9B372a8;

contract MultiMarket is Ownable, Utils {
    IERC20 public currencyToken;
    mapping(address => uint) public balances;

    constructor(address _currencyToken) Ownable(msg.sender) {
        require(_currencyToken != address(0), "Invalid currency address");
        require(
            _isERC20(_currencyToken),
            "Address is not a valid ERC-20 token"
        );
        currencyToken = IERC20(_currencyToken);
    }
}
