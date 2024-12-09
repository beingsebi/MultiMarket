// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Utils {
    /**
     * @dev Minimal check if an address is an ERC20 token. False positives are possible.
     * @param _tokenAddress Address to check.
     * @return True if the address is an ERC20 token, false otherwise.
     */
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
}
