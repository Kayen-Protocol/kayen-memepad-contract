// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

interface IDistributor {
    function distribute(address token0, address token1, uint160 sqrtPriceX96, uint256 deadline) external;
    function getPoolAddress(address token0, address token1) external returns (address);
    function canDistribute(address token0, address token1) external view returns (bool);
}