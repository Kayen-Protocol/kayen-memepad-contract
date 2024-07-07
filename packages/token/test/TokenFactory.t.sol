// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenFactory} from "../contracts/TokenFactory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFactoryTest is Test {
    TokenFactory public factory;

    function setUp() public {
        factory = new TokenFactory();
    }

    function test_create() public {
        address token = factory.create("Test", "TEST", 1e18);
        IERC20 tokenInstance = IERC20(token);

        assert(tokenInstance.totalSupply() == 1e18);
        assert(tokenInstance.balanceOf(address(this)) == 1e18);
    }

    function test_create_multiple() public {
        address token = factory.create("Test", "TEST", 1e18);
        address token2 = factory.create("Test", "TEST", 5e18);
        IERC20 tokenInstance = IERC20(token);
        IERC20 tokenInstance2 = IERC20(token2);

        assert(tokenInstance.totalSupply() == 1e18);
        assert(tokenInstance.balanceOf(address(this)) == 1e18);
        assert(tokenInstance2.totalSupply() == 5e18);
        assert(tokenInstance2.balanceOf(address(this)) == 5e18);
    }
}
