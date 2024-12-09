// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./00_Utils.sol";

contract TokenHolder is Utils {
    // Event emitted when a deposit is made
    event Deposit(address indexed user, uint amount);
    // Event emitted when a withdrawal is made
    event Withdraw(address indexed user, uint amount);

    // ERC20 token used as currency in the contract
    IERC20 public immutable currencyToken;

    // Decimals of the currency token
    // x / 10^decimals = x tokens
    uint16 public immutable decimals;

    mapping(address => uint) public balances;

    /**
     * @dev Constructor that sets the currency token and initializes the Ownable contract.
     * @param _currencyToken Address of the ERC20 token to be used as currency.
     */
    constructor(address _currencyToken, uint16 _decimals) {
        require(_currencyToken != address(0), "Invalid currency address");
        require(
            _isERC20(_currencyToken),
            "Address is not a valid ERC-20 token"
        );
        currencyToken = IERC20(_currencyToken);
        decimals = _decimals;
    }

    /**
     * @dev Function to deposit a specified amount of currency tokens into the contract.
     * @param _amount The amount of currency tokens to deposit.
     */
    function deposit(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        // uint allowance = currencyToken.allowance(msg.sender, address(this));
        // require(allowance >= _amount, "Allowance is not sufficient");

        bool success = currencyToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(success, "Transfer failed");

        balances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @dev Function to withdraw a specified amount of currency tokens from the contract.
     * @param _amount The amount of currency tokens to withdraw.
     */
    function withdraw(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        bool success = currencyToken.transfer(msg.sender, _amount);
        require(success, "Transfer failed");

        balances[msg.sender] -= _amount;

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @dev Function to get the balance of a user in the contract.
     * @param _user The address of the user.
     * @return The balance of the user.
     */
    function _getBalance(address _user) internal view returns (uint) {
        return balances[_user];
    }
}
