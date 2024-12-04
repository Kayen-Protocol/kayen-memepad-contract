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
import {UniswapV2Library} from "@kayen/uniswap-v2-periphery/contracts/libraries/UniswapV2Library.sol";

import "../../Setup.sol";

contract AutoDistributeTest is Setup {
    using Path for bytes;

    IPresale presale;
    uint24 poolFee = 100;

    function setUp() public override {
        super.setUp();
        vm.stopPrank();
        vm.startPrank(deployer);
        {
            configuration.putDefaultDistributor(address(uniswapV3Distributor));
        }
        vm.stopPrank();
        vm.startPrank(user1);
        {
            presale = uniswapV3PresaleMaker.startWithNewToken(
                user1,
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

    function test_auto_distribute() external {
        assertTrue(presale.getProgress() == 0);

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

        assert(presale.info().isEnd);
    }
}
