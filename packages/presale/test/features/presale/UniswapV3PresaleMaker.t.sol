// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import "../../Setup.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UniswapV3PresaleMakerTest is Setup {

    function test_create_presale() external {
        vm.startPrank(user1);
        {
            uniswapV3PresaleMaker.startWithNewToken(
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
    }

    function test_should_fail_when_not_whitelisted_payment_token() external {
        ERC20 testToken = new ERC20("Test", "TEST");
        vm.startPrank(user1);
        {
            vm.expectRevert();
            uniswapV3PresaleMaker.startWithNewToken(
                address(testToken),
                "Trump Frog",
                "TROG",
                1000000000e18,
                7922816251426433759354395,
                -180162,
                23027,
                100000000e18,
                100e18,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();
    }

    function test_create_presale_without_new_token() external {
        vm.startPrank(user1);
        {
            ERC20 memeToken = new MockERC20("Meme", "MEME", 1000000000e18);
            memeToken.approve(address(uniswapV3PresaleMaker), 1000000000e18);
            uniswapV3PresaleMaker.start(
                address(weth),
                address(memeToken),
                25054144837504793118641380,
                -180162,
                -177285,
                1000000000e18,
                10e18,
                0,
                0,
                ""
            );
        }
        vm.stopPrank();
    }
}
