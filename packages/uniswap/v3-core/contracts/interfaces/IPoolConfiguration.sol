// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPoolConfiguration {
    function getTradeFee(address token0, address token1) external view returns (uint24);
    function getFeeVault() external view returns (address);
    function beforeSwap(address pool, address recipient) external;
    function isWhitelistedMaker(address target) external view returns (bool);
}