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

contract BlockTransferTest is Setup {
    IPresale presale;
    MockDistributor mockDistributor;
    uint24 poolFee = 100;

    function setUp() public override {
        super.setUp();
        mockDistributor = new MockDistributor();
        vm.startPrank(deployer);
        {
            configuration.allowDistributor(address(mockDistributor));
            configuration.putTransferBlacklist(user2);
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

    function test_block_transfer() external {
        vm.startPrank(user1);
        {
            swapRouter.exactInput{value: 10e18}(ISwapRouter.ExactInputParams(
                abi.encodePacked(address(weth), poolFee, presale.info().token),
                address(this),
                block.timestamp + 10,
                10e18,
                0
            ));
            IERC20 tokenInstance = IERC20(presale.info().token);
            uint256 balance = tokenInstance.balanceOf(user1);
            vm.expectRevert();
            tokenInstance.transfer(user2, balance);
        }
        vm.stopPrank();

        vm.startPrank(deployer);
        {
            configuration.removeTransferBlacklist(user2);
        }
        vm.stopPrank();

        vm.startPrank(user1);
        {
            IERC20 tokenInstance = IERC20(presale.info().token);
            tokenInstance.transfer(user2, tokenInstance.balanceOf(user1));
        }
        vm.stopPrank();
    }

    function test_block_transfer_off_after_distribute() external {
        vm.startPrank(user1);
        {
            swapRouter.exactInput{value: 10e18}(ISwapRouter.ExactInputParams(
                abi.encodePacked(address(weth), poolFee, presale.info().token),
                address(this),
                block.timestamp + 10,
                10e18,
                0
            ));
            
            presale.distribute(mockDistributor, abi.encode(user1));
            IERC20(presale.info().token).transfer(user2, 10e18);
        }
        vm.stopPrank();
    }
}
