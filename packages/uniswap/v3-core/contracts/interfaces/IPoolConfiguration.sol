// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPoolConfiguration {
    function isPaused(address pool) external view returns (bool);
    function isPausedAll() external view returns (bool);
    function getTradeFee(address token0, address token1) external view returns (uint24);
    function getFeeVault() external view returns (address);
}