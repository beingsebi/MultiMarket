// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenHolder is Ownable {
    // ERC20 token used as currency in the contract
    IERC20 public immutable currencyTokenContract;
    uint public contractBalance;
    // Decimals of the currency token
    // x / 10^decimals = x tokens
    uint16 public immutable decimals;
    // 3 => minPrice = 1e-3 tokens
    uint16 public immutable granularity;
    mapping(address => uint) public freeBalances;
    mapping(address => uint) public reservedBalances;
    //balance=reserved+free

    // Event emitted when a deposit is made
    event Deposit(address indexed user, uint amount);
    // Event emitted when a withdrawal is made
    event Withdraw(address indexed user, uint amount);

    mapping(address => bool) public isMarket;

    modifier onlyMarket() {
        require(isMarket[msg.sender], "Only market can call this function");
        _;
    }

    /**
     * @dev Constructor that sets the currency token and initializes the Ownable contract.
     * @param _currencyToken Address of the ERC20 token to be used as currency.
     * @param _decimals Decimals of the currency token.
     * @param _granularity Granularity of the currency token when placing orders.
     */
    constructor(
        address _currencyToken,
        uint16 _decimals,
        uint16 _granularity
    ) Ownable(msg.sender) {
        require(_currencyToken != address(0), "Invalid currency address");
        require(
            _isERC20(_currencyToken),
            "Address is not a valid ERC-20 token"
        );
        require(_granularity >= 0, "Granularity must be >= 0");
        require(_decimals >= _granularity, "Decimals must be >= granularity");

        currencyTokenContract = IERC20(_currencyToken);
        decimals = _decimals;
        granularity = _granularity;
    }

    /**
     * @dev Function to deposit a specified amount of currency tokens into the contract.
     * @param _amount The amount of currency tokens to deposit.
     */
    function deposit(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        bool success = currencyTokenContract.transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        require(success, "Transfer failed");

        freeBalances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @dev Function to withdraw a specified amount of currency tokens from the contract.
     * @param _amount The amount of currency tokens to withdraw.
     */
    function withdraw(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(freeBalances[msg.sender] >= _amount, "Insufficient balance");
        require(
            freeBalances[msg.sender] - reservedBalances[msg.sender] >= _amount,
            "Funds are reserved in orders. Cancel orders first."
        );

        bool success = currencyTokenContract.transfer(msg.sender, _amount);
        require(success, "Transfer failed");

        freeBalances[msg.sender] -= _amount;

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @dev Function to donate a specified amount of ETH to the contract.
     */
    function donateEth() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
    }

    /**
     * @dev Function to donate a specified amount of currency tokens to the contract.
     * @param _amount The amount of currency tokens to donate.
     */
    function donateCurrency(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        bool success = currencyTokenContract.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(success, "Transfer failed");
    }

    /**
     * @dev Function to withdraw a specified amount of ETH from the contract.
     * @param _amount The amount of ETH to withdraw.
     */
    function withdrawEth(uint _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= _amount, "Insufficient balance");

        payable(owner()).transfer(_amount);
    }

    /**
     * @dev Function to withdraw a specified amount of currency tokens from the contract.
     * @param _amount The amount of currency tokens to withdraw.
     */
    function withdrawCurrency(uint _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        require(contractBalance >= _amount, "Insufficient balance");

        bool success = currencyTokenContract.transfer(owner(), _amount);
        require(success, "Transfer failed");
        contractBalance -= _amount;
    }

    function _isERC20(address _tokenAddress) internal view returns (bool) {
        try IERC20(_tokenAddress).totalSupply() returns (uint) {
            try IERC20(_tokenAddress).balanceOf(address(this)) returns (uint) {
                return true;
            } catch {
                return false;
            }
        } catch {
            return false;
        }
    }

    function transferReserved(
        address from,
        address to,
        uint amount
    ) external onlyMarket {
        require(reservedBalances[from] >= amount, "Insufficient balance");
        reservedBalances[from] -= amount;
        reservedBalances[to] += amount;
    }
}
