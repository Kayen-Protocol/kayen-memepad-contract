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

    function test_distribute() external {
        vm.startPrank(user2);
        {
            vm.expectRevert();
            presale.distribute(mockDistributor, abi.encode(user1));
        }
        vm.stopPrank();

        uint256 amountOut;
        vm.startPrank(user2);
        {
            amountOut = swapRouter.exactInput{value: 10e18}(
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
            presale.distribute(mockDistributor, abi.encode(user1));
        }
        vm.stopPrank();

        assertTrue(IERC20(presale.info().token).balanceOf(address(presale)) == 0);
        assertTrue(weth.balanceOf(address(presale)) == 0);

        assert(weth.balanceOf(address(user1)) > 99e17);
    }

}
