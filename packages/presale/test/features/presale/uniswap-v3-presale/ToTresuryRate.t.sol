// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {IPresale} from "../../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../../contracts/presale/UniswapV3Presale.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "./UniswapV3Presale.t.sol";

contract UniswapV3PresaleFunctionTest is UniswapV3PresaleTest {

    function test_to_tresury_rate() external {
        uint24 toTresuryRato = 5e5;
        vm.startPrank(user);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken(
                user,
                address(0),
                "Trump Frog",
                "TROG",
                totalSupply,
                7922816251426433759354395,
                -180162,
                23027,
                totalSupply,
                10e18,
                0,
                toTresuryRato,
                0,
                block.timestamp + 100,
                ""
            );
        }
        vm.stopPrank();

        vm.startPrank(user2);
        {
            swapRouter.exactInput{value: 11e18}(
                ISwapRouter.ExactInputParams(
                    abi.encodePacked(address(weth), poolFee, presale.info().token),
                    address(user2),
                    block.timestamp + 10,
                    11e18,
                    0
                )
            );
        }
        vm.stopPrank();


        vm.startPrank(user);
        {
            assertTrue(presale.getProgress() >= 1e6);
            presale.distribute(address(uniswapV2Distributor), block.timestamp + 100);

            uint256 expectedEth = 10e18 / 2 * 99e16 / 1e18;
            uint256 expectedToken = (totalSupply - IERC20(presale.info().token).balanceOf(user2)) / 2  * 99e16 / 1e18;

            assertTrue(weth.balanceOf(user) >= expectedEth);
            assertTrue(IERC20(presale.info().token).balanceOf(user) >= expectedToken);
        }
        vm.stopPrank();
    }
}
