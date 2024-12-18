// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

interface ITokenHolder {
    function transferFromReserved(
        address from,
        address to,
        uint amount
    ) external;

    function transferFromFree(address from, address to, uint amount) external;

    function freeBalances(address) external view returns (uint);
}
