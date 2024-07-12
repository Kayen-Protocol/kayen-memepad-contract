// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {MockDistributor} from "../../mocks/MockDistributor.sol";
import {IPresale} from "../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../contracts/presale/UniswapV3Presale.sol";

import {Path} from "@kayen/uniswap-v3-periphery/contracts/libraries/Path.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "../../Setup.sol";

contract UniswapV3PresaleTest is Setup {
    uint24 poolFee = 100;
    using Path for bytes;

    function setUp() public override {
        super.setUp();
        vm.startPrank(deployer);
        {
            configuration.putDefaultTradeFee(1e6 / 50); // set 2%
            bera.transfer(user2, 10e18);
        }
        vm.stopPrank();
    }

    function test_trade_fee() external {
        IPresale presale;
        vm.startPrank(user1);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken(
                address(weth),
                "Trump Frog",
                "TROG",
                1000000000e18,
                7922816251426433759354395,
                -180162,
                23027,
                1000000000e18,
                10e18,
                0,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();
        vm.deal(user2, 20 ether);
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
        assertTrue(weth.balanceOf(configuration.feeVault()) >= 2e17);
    }

    function test_trade_fee_with_erc20_payment() external {
        IPresale presale;
        vm.startPrank(user1);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken(
                address(bera),
                "Trump Frog",
                "TROG",
                1000000000e18,
                7922816251426433759354395,
                -180162,
                23027,
                1000000000e18,
                10e18,
                0,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();
        vm.startPrank(user2);
        {
            bera.approve(address(swapRouter), 10e18);
            uint256 amountOut = swapRouter.exactInput(
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
        assertTrue(bera.balanceOf(configuration.feeVault()) >= 2e17);
    }

    function test_trade_fee_discount() external {
        vm.startPrank(deployer);
        {
            configuration.putTradeFeeForToken(address(bera), 1e6 / 100); // set 1%
        }
        vm.stopPrank();

        IPresale presale;
        vm.startPrank(user1);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken(
                address(bera),
                "Trump Frog",
                "TROG",
                1000000000e18,
                7922816251426433759354395,
                -180162,
                23027,
                1000000000e18,
                10e18,
                0,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();
        vm.startPrank(user2);
        {
            bera.approve(address(swapRouter), 10e18);
            uint256 amountOut = swapRouter.exactInput(
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
        assertTrue(bera.balanceOf(configuration.feeVault()) < 2e17);
        assertTrue(bera.balanceOf(configuration.feeVault()) >= 1e17);
    }

}
