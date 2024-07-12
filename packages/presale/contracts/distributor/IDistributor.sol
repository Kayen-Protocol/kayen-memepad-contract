// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

interface IDistributor {
    function distribute(address token0, address token1, uint256 expectedPriceZeroToOne, bytes calldata data) external;
}