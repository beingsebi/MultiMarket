// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

interface ITokenHolder {
    function transferReserved(address from, address to, uint amount) external;
}
