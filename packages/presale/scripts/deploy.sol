// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {Script, console2} from "forge-std/Script.sol";

import {Configuration} from "../contracts/Configuration.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address wchz = address(0x678c34581db0a7808d0aC669d7025f1408C9a3C6);

        Configuration configuration = new Configuration(feeVault);
        PresaleManager presaleManager = new PresaleManager(configuration);
        TokenFactory tokenFactory = new TokenFactory();
        UniswapV3Factory poolFactory = new UniswapV3Factory(configuration);
        NonfungibleTokenPositionDescriptor tokenDescriptor = new NonfungibleTokenPositionDescriptor(
            wchz,
            bytes32("WCHZ")
        );
        NonfungiblePositionManager positionManager = new NonfungiblePositionManager(
            address(poolFactory),
            wchz,
            address(tokenDescriptor)
        );
        SwapRouter swapRouter = new SwapRouter(address(poolFactory), wchz);
        UniswapV3PresaleMaker uniswapV3PresaleMaker = new UniswapV3PresaleMaker(
            configuration,
            presaleManager,
            tokenFactory,
            poolFactory,
            positionManager,
            swapRouter,
            wchz
        );

        vm.stopBroadcast();
    }
}
