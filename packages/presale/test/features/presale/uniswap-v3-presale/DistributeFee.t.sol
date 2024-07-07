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

    function test_distribute_fee() external {
        vm.startPrank(deployer);
        {
            configuration.putDefaultDistributionFeeRate(5e6 / 100); // 5%
        }
        vm.stopPrank();

        vm.startPrank(user2);
        {
            swapRouter.exactInput{value: 10e18}(
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
        vm.startPrank(user1);
        {
            presale.distribute(mockDistributor, abi.encode(user1));
        }
        vm.stopPrank();
        assertTrue(weth.balanceOf(configuration.feeVault()) >= 10e18 * 5e6 / 100 / 1e6 * 99 / 100);
    }

    function test_distribute_fee_discount() external {
        vm.startPrank(deployer);
        {
            bera.transfer(user2, 10e18);
            configuration.putDefaultDistributionFeeRate(5e6 / 100); // 5%
            configuration.putDistributionFeeRateForToken(address(bera), 1e6 / 100); // 1%
            presale = uniswapV3PresaleMaker.startWithNewToken(
                address(bera),
                "Trump Frog",
                "TROG",
                totalSupply,
                7922816251426433759354395,
                -180162,
                23027,
                totalSupply,
                10e18,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();

        vm.startPrank(user2);
        {
            bera.approve(address(swapRouter), 10e18);
            swapRouter.exactInput(
                ISwapRouter.ExactInputParams(
                    abi.encodePacked(address(bera), poolFee, presale.info().token),
                    address(this),
                    block.timestamp + 10,
                    10e18,
                    0
                )
            );
        }
        vm.stopPrank();

        assertTrue(presale.getProgress() == 100);
        vm.startPrank(user1);
        {
            presale.distribute(mockDistributor, abi.encode(user1));
        }
        vm.stopPrank();
        
        console.log(bera.balanceOf(configuration.feeVault()));
        assertTrue(bera.balanceOf(configuration.feeVault()) >= 10e18 * 1e6 / 100 / 1e6 * 99 / 100);
    }
}
