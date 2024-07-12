// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {IDistributor} from "./IDistributor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Configuration} from "../Configuration.sol";

abstract contract Distributor is IDistributor {
    Configuration internal config;

    constructor(Configuration _config) {
        config = _config;
    }

    function distribute(address token0, address token1, uint256 expectedPriceZeroToOne, bytes calldata data) external override {
        _doDistribute(token0, token1, expectedPriceZeroToOne, data);
        sendRestToVault(token0, token1);
    }

    function _doDistribute(address token0, address token1, uint256 expectedPrice, bytes calldata data) internal virtual;

    function sendRestToVault(address token0, address token1) internal {
        IERC20(token0).transfer(config.feeVault(), IERC20(token0).balanceOf(address(this)));
        IERC20(token1).transfer(config.feeVault(), IERC20(token1).balanceOf(address(this)));
    }

}