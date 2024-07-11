// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {IPresale} from "../../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../../contracts/presale/UniswapV3Presale.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "./UniswapV3Presale.t.sol";

contract UniswapV3PresaleFunctionTest is UniswapV3PresaleTest {

    function test_buy_instantly() external {
        vm.startPrank(user2);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken{value: 11e18}(
                address(weth),
                "Trump Frog",
                "TROG",
                1000000000e18,
                7922816251426433759354395,
                -180162,
                23027,
                1000000000e18,
                10e18,
                1e18,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();
        assertTrue(presale.getProgress() == 10);
    }

}
