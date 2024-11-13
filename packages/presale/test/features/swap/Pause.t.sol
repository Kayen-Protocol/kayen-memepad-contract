// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {MockDistributor} from "../../mocks/MockDistributor.sol";
import {IPresale} from "../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../contracts/presale/UniswapV3Presale.sol";

import {PoolAddress} from "@kayen/uniswap-v3-periphery/contracts/libraries/PoolAddress.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "../../Setup.sol";

contract UniswapV3PresaleTest is Setup {
    IPresale presale1;
    IPresale presale2;
    uint24 poolFee = 100;

    function setUp() public override {
        super.setUp();
        vm.startPrank(user1);
        {
            presale1 = uniswapV3PresaleMaker.startWithNewToken(
                msg.sender,
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
                block.timestamp + 100,
                ""
            );
            presale2 = uniswapV3PresaleMaker.startWithNewToken(
                msg.sender,
                address(weth),
                "Trump Frog2",
                "TROG2",
                1000000000e18,
                7922816251426433759354395,
                -180162,
                23027,
                1000000000e18,
                10e18,
                0,
                0,
                0,
                block.timestamp + 100,
                ""
            );
        }
        vm.stopPrank();
        vm.deal(user2, 30 ether);
    }

    function test_pause_trade_pool() external {
        vm.startPrank(deployer);
        {
            configuration.pause(presale1.info().pool);
        }
        vm.stopPrank();

        ISwapRouter.ExactInputParams memory params1 = ISwapRouter.ExactInputParams(
            abi.encodePacked(address(weth), poolFee, presale1.info().token),
            address(this),
            block.timestamp + 10,
            11e18,
            0
        );
        ISwapRouter.ExactInputParams memory params2 = ISwapRouter.ExactInputParams(
            abi.encodePacked(address(weth), poolFee, presale2.info().token),
            address(this),
            block.timestamp + 10,
            11e18,
            0
        );

        vm.startPrank(user2);
        {
            vm.expectRevert();
            swapRouter.exactInput{value: 11e18}(params1);

            swapRouter.exactInput{value: 11e18}(params2);
        }
        vm.stopPrank();

        vm.startPrank(deployer);
        {
            configuration.unpause(presale1.info().pool);
        }
        vm.stopPrank();

        vm.startPrank(user2);
        {
            swapRouter.exactInput{value: 11e18}(params1);
        }
        vm.stopPrank();
    }

    function test_pause_trade_all_pool() external {
        vm.startPrank(deployer);
        {
            configuration.pauseAll();
        }
        vm.stopPrank();

        ISwapRouter.ExactInputParams memory params1 = ISwapRouter.ExactInputParams(
            abi.encodePacked(address(weth), poolFee, presale1.info().token),
            address(this),
            block.timestamp + 10,
            10e18,
            0
        );
        ISwapRouter.ExactInputParams memory params2 = ISwapRouter.ExactInputParams(
            abi.encodePacked(address(weth), poolFee, presale2.info().token),
            address(this),
            block.timestamp + 10,
            1e18,
            0
        );
        vm.startPrank(user2);
        {
            vm.expectRevert();
            swapRouter.exactInput{value: 10e18}(params1);

            vm.expectRevert();
            swapRouter.exactInput{value: 1e18}(params2);
        }
        vm.stopPrank();

        vm.startPrank(deployer);
        {
            configuration.unpauseAll();
        }
        vm.stopPrank();

        vm.startPrank(user2);
        {
            swapRouter.exactInput{value: 10e18}(params1);
            swapRouter.exactInput{value: 1e18}(params2);
        }
        vm.stopPrank();
    }
}
