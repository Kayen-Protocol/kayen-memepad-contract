// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TokenFactory} from "../contracts/TokenFactory.sol";

contract TokenFactoryScript is Script {
    function setUp() public {}

    function run() public {
        TokenFactory factory = new TokenFactory();
        vm.broadcast();
    }
}
