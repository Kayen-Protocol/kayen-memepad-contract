// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {MockDistributor} from "../../mocks/MockDistributor.sol";
import {IPresale} from "../../../contracts/presale/IPresale.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {Path} from "@kayen/uniswap-v3-periphery/contracts/libraries/Path.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../Setup.sol";

contract UniswapV2DistributorTest is Setup {
    IPresale presale;
    MockDistributor mockDistributor;
    uint24 poolFee = 100;
    using Path for bytes;

    function setUp() public override {
        super.setUp();
        mockDistributor = new MockDistributor();
        vm.startPrank(deployer);
        {
            configuration.allowDistributor(address(mockDistributor));
        }
        vm.stopPrank();
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
                ""
            );
        }
        vm.stopPrank();
        vm.deal(user2, 20 ether);
    }

    function test_distribute() external {
        MockERC20 token0 = new MockERC20("Test1", "TEST1", 1000000000e18);
        MockERC20 token1 = new MockERC20("Test2", "TEST2", 1000000000e18);
        token0.transfer(address(uniswapV2Distributor), 1000000000e18);
        token1.transfer(address(uniswapV2Distributor), 1000000000e18);
        uniswapV2Distributor.distribute(address(token0), address(token1), 1e18, abi.encode(user1));
    }

    function test_distribute_by_presale() external {
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
        vm.startPrank(user2);
        {
            presale.distribute(uniswapV2Distributor, abi.encode(user1));
        }
        vm.stopPrank();
    }

    function test_fail_distribute_when_price_differ() external {
        vm.startPrank(user2);
        {
            uint256 amountOut = swapRouter.exactInput{value: 10e18}(
                ISwapRouter.ExactInputParams(
                    abi.encodePacked(address(weth), poolFee, presale.info().token),
                    address(user2),
                    block.timestamp + 10,
                    10e18,
                    0
                )
            );
            address pool = externalV2Factory.createPair(address(weth), presale.info().token);
            IERC20(presale.info().token).approve(address(externalV2SwapRouter), amountOut);
            externalV2SwapRouter.addLiquidityETH{value: 1e18}(
                presale.info().token,
                amountOut,
                0,
                0,
                address(this),
                block.timestamp + 10
            );
        }
        vm.stopPrank();
        assertTrue(presale.getProgress() == 100);
        vm.startPrank(user2);
        {
            vm.expectRevert();
            presale.distribute(uniswapV2Distributor, abi.encode(user1));
        }
        vm.stopPrank();
    }
}
