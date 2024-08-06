// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {MockDistributor} from "../../../mocks/MockDistributor.sol";
import {IPresale} from "../../../../contracts/presale/IPresale.sol";
import {UniswapV3Presale} from "../../../../contracts/presale/UniswapV3Presale.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "../../../Setup.sol";

contract UniswapV3PresaleTest is Setup {
    IPresale presale;
    MockDistributor mockDistributor;
    uint24 poolFee = 100;
    uint256 totalSupply = 1000000000e18;

    function setUp() public override {
        super.setUp();
        mockDistributor = new MockDistributor(user1);
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
                totalSupply,
                7922816251426433759354395,
                -180162,
                23027,
                totalSupply,
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
}
