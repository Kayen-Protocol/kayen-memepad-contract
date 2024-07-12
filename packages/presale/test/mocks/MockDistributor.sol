// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import { IDistributor } from "../../contracts/distributor/IDistributor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockDistributor is IDistributor {

    function distribute(address token0, address token1, uint256 expectedPrice, bytes calldata data) external override {
        (address target) = abi.decode(data, (address));
        IERC20(token0).transfer(target, IERC20(token0).balanceOf(address(this)));
        IERC20(token1).transfer(target, IERC20(token1).balanceOf(address(this)));
    }
}