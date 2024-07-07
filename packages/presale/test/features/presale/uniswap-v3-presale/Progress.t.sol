// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import "forge-std/console.sol";

import {IPresale} from "../../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../../contracts/presale/UniswapV3Presale.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "./UniswapV3Presale.t.sol";

contract UniswapV3PresaleFunctionTest is UniswapV3PresaleTest {

    function test_progress() external {
        assertTrue(presale.getProgress() == 0);

        vm.startPrank(user2);
        {
            uint256 amountOut = swapRouter.exactInput{value: 10e18}(
                ISwapRouter.ExactInputParams(
                    abi.encodePacked(address(weth), poolFee, presale.info().token),
                    address(this),
                    block.timestamp + 10,
                    10e18,
                    0
                )
            );
        }
        vm.stopPrank();
        assertTrue(presale.getProgress() == 100);
    }

}
