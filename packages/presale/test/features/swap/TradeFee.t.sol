// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {MockDistributor} from "../../mocks/MockDistributor.sol";
import {IPresale} from "../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../contracts/presale/UniswapV3Presale.sol";

import {Path} from "@kayen/uniswap-v3-periphery/contracts/libraries/Path.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IUniswapV3PoolEvents} from "@kayen/uniswap-v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol";
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
                block.timestamp + 100,
                ""
            );
        }
        vm.stopPrank();
        vm.deal(user2, 30 ether);
        vm.startPrank(user2);
        {
            uint256 amountOut = swapRouter.exactInput{value: 11e18}(
                ISwapRouter.ExactInputParams(
                    abi.encodePacked(address(weth), poolFee, presale.info().token),
                    address(this),
                    block.timestamp + 10,
                    11e18,
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
                block.timestamp + 100,
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
                block.timestamp + 100,
                ""
            );
        }
        vm.stopPrank();
        uint256 amountOut;
        vm.startPrank(user2);
        {
            bera.approve(address(swapRouter), 10e18);

            vm.recordLogs();
            amountOut = swapRouter.exactInput(
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

        Vm.Log[] memory entries = vm.getRecordedLogs();
        uint256 idx = 0;
        int256 originalAmount0;
        int256 originalAmount1;
        int256 feeExcludedAmount0;
        int256 feeExcludedAmount1;
        for (; idx < entries.length; idx++) {
            if (entries[idx].topics[0] == IUniswapV3PoolEvents.Swap.selector) {
                (int256 amount0, int256 amount1, uint160 c, uint128 d, int24 e) = abi.decode(
                    entries[idx].data,
                    (int256, int256, uint160, uint128, int24)
                );
                originalAmount0 = amount0;
                originalAmount1 = amount1;
            }
            if (entries[idx].topics[0] == IUniswapV3PoolEvents.SwapFeeExcluded.selector) {
                (int256 amount0, int256 amount1, uint160 c, uint128 d, int24 e) = abi.decode(
                    entries[idx].data,
                    (int256, int256, uint160, uint128, int24)
                );
                feeExcludedAmount0 = amount0;
                feeExcludedAmount1 = amount1;
            }
        }
        console.log(Strings.toString(originalAmount0));
        console.log(Strings.toString(originalAmount1));
        console.log(Strings.toString(feeExcludedAmount0));
        console.log(Strings.toString(feeExcludedAmount1));
        console.log(bera.balanceOf(configuration.feeVault()));
        assertTrue(feeExcludedAmount1 + int256(bera.balanceOf(configuration.feeVault())) == originalAmount1);
    }
}
