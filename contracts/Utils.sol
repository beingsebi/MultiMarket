// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Utils {
    function _isERC20(address _tokenAddress) internal view returns (bool) {
        // minimal check; false positives are possible
        try IERC20(_tokenAddress).totalSupply() returns (uint256) {
            try IERC20(_tokenAddress).balanceOf(address(this)) returns (
                uint256
            ) {
                return true;
            } catch {
                return false;
            }
        } catch {
            return false;
        }
    }
}
