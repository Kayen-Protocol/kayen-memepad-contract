// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {IDistributor} from "./IDistributor.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Configuration} from "../Configuration.sol";

abstract contract Distributor is IDistributor {
    using SafeERC20 for IERC20;
    Configuration internal immutable config;

    constructor(Configuration _config) {
        config = _config;
    }

    function distribute(address token0, address token1, uint160 sqrtPriceX96, uint256 deadline) external override {
        _doDistribute(token0, token1, sqrtPriceX96, deadline);
        sendRestToVault(token0, token1);
    }

    function _doDistribute(address token0, address token1, uint160 sqrtPriceX96, uint256 deadline) internal virtual;

    function sendRestToVault(address token0, address token1) internal {
        IERC20(token0).safeTransfer(config.feeVault(), IERC20(token0).balanceOf(address(this)));
        IERC20(token1).safeTransfer(config.feeVault(), IERC20(token1).balanceOf(address(this)));
    }

}