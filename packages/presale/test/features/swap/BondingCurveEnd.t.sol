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
    IPresale presale;
    uint24 poolFee = 100;

    function setUp() public override {
        super.setUp();
        vm.startPrank(user1);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken(
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
        }
        vm.stopPrank();
        vm.deal(user2, 30 ether);
    }

    function test_stop_trade_after_bonding_curve_end() external {
        vm.startPrank(user1);
        {
            swapRouter.exactInput{value: 11e18}(ISwapRouter.ExactInputParams(
                abi.encodePacked(address(weth), poolFee, presale.info().token),
                address(this),
                block.timestamp + 10,
                11e18,
                0
            ));
        }
        vm.stopPrank();


        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams(
            abi.encodePacked(address(weth), poolFee, presale.info().token),
            address(this),
            block.timestamp + 10,
            1e18,
            0
        );

        vm.startPrank(user2);
        {
            vm.expectRevert();
            swapRouter.exactInput{value: 1e18}(params);
        }
        vm.stopPrank();
    }

}
