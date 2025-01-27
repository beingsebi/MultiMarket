// SPDX-License-Identifier: MIT
// for running locally
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDC is ERC20, Ownable {
    uint256 private constant _initialSupply = 42e9;
    uint256 private constant _salesTaxRate = 0; // 7%

    constructor(
        address initialOwner
    ) ERC20("USDC Token", "USDC") Ownable(msg.sender) {
        _mint(initialOwner, _initialSupply * 10 ** decimals());
        _mint(
            address(0xdD2FD4581271e230360230F9337D5c0430Bf44C0),
            _initialSupply * 10 ** decimals()
        );
        transferOwnership(initialOwner);
    }

    // Override decimals to set it to 6
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 taxAmount = (amount * _salesTaxRate) / 100;
        uint256 netAmount = amount - taxAmount;

        _transfer(_msgSender(), recipient, netAmount);
        _transfer(_msgSender(), owner(), taxAmount);

        return true;
    }

    // Function to allow the owner to mint more tokens (for potential forking)
    function mint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }
}
