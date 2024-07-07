// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {Script, console2} from "forge-std/Script.sol";

import {Configuration} from "../contracts/Configuration.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address weth = address(0);

        Configuration configuration = new Configuration(feeVault);
        PresaleManager presaleManager = new PresaleManager(configuration);
        TokenFactory tokenFactory = new TokenFactory();
        UniswapV3Factory poolFactory = new UniswapV3Factory(configuration);
        NonfungibleTokenPositionDescriptor tokenDescriptor = new NonfungibleTokenPositionDescriptor(
            weth,
            bytes32("WETH")
        );
        NonfungiblePositionManager positionManager = new NonfungiblePositionManager(
            address(poolFactory),
            weth,
            address(tokenDescriptor)
        );
        SwapRouter swapRouter = new SwapRouter(address(poolFactory), weth);
        UniswapV3PresaleMaker uniswapV3PresaleMaker = new UniswapV3PresaleMaker(
            configuration,
            presaleManager,
            tokenFactory,
            poolFactory,
            positionManager,
            swapRouter,
            weth
        );

        vm.stopBroadcast();
    }
}
