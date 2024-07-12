// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {MockDistributor} from "../../mocks/MockDistributor.sol";
import {IPresale} from "../../../contracts/presale/IPresale.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {Path} from "@kayen/uniswap-v3-periphery/contracts/libraries/Path.sol";
import {IUniswapV3Pool} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
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
        token0.transfer(address(uniswapV3Distributor), 1000000000e18);
        token1.transfer(address(uniswapV3Distributor), 1000000000e18);

        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(presale.info().pool).slot0();

        uniswapV3Distributor.distribute(address(token0), address(token1), 1e18, abi.encode(sqrtPriceX96, poolFee));
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

        vm.startPrank(user2);
        {
            (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(presale.info().pool).slot0();
            vm.expectRevert();
            presale.distribute(uniswapV3Distributor, abi.encode(sqrtPriceX96, poolFee));
        }
        vm.stopPrank();

        vm.startPrank(user1);
        {
            (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(presale.info().pool).slot0();
            presale.distribute(uniswapV3Distributor, abi.encode(sqrtPriceX96, poolFee));
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
            IUniswapV3Pool pool = IUniswapV3Pool(
                externalV3Factory.createPool(address(weth), presale.info().token, poolFee)
            );
            pool.initialize(7922816251426433759354395);
            IERC20(presale.info().token).approve(address(externalV3PositionManager), amountOut);
            externalV3PositionManager.mint(
                INonfungiblePositionManager.MintParams({
                    token0: pool.token0(),
                    token1: pool.token1(),
                    fee: pool.fee(),
                    tickLower: -100000,
                    tickUpper: 100000,
                    amount0Desired: pool.token0() == presale.info().token ? amountOut : 0,
                    amount1Desired: pool.token1() == presale.info().token ? amountOut : 0,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: address(user2),
                    deadline: block.timestamp + 100
                })
            );
        }
        vm.stopPrank();
        vm.startPrank(user2);
        {
            (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(presale.info().pool).slot0();
            vm.expectRevert();
            presale.distribute(uniswapV3Distributor, abi.encode(sqrtPriceX96, poolFee));
        }
        vm.stopPrank();
    }
}
