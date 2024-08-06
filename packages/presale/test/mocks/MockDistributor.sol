// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import { IDistributor } from "../../contracts/distributor/IDistributor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockDistributor is IDistributor {
    address public target;
    constructor(address _target) {
        target = _target;
    }

    function getPoolAddress(address token0, address token1) external view override returns (address) {
        return address(0);
    }

    function canDistribute(address token0, address token1) public view override returns (bool) {
        return true;
    }

    function distribute(address token0, address token1, uint160 sqrtPriceX96, uint256 deadline) external override {
        IERC20(token0).transfer(target, IERC20(token0).balanceOf(address(this)));
        IERC20(token1).transfer(target, IERC20(token1).balanceOf(address(this)));
    }
}