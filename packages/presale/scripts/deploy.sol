// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import {Script, console2} from "forge-std/Script.sol";

import {Configuration} from "../contracts/Configuration.sol";
import {PresaleManager} from "../contracts/presale-manager/PresaleManager.sol";
import {PresalePoolManager} from "../contracts/PresalePoolManager.sol";
import {UniswapV3PresaleMaker} from "../contracts/presale/UniswapV3PresaleMaker.sol";

import {TokenFactory} from "@kayen/token/contracts/TokenFactory.sol";
import {UniswapV3Factory} from "@kayen/uniswap-v3-core/contracts/UniswapV3Factory.sol";
import {NonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/NonfungiblePositionManager.sol";
import {NonfungibleTokenPositionDescriptor} from "@kayen/uniswap-v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";
import {Quoter} from "@kayen/uniswap-v3-periphery/contracts/lens/Quoter.sol";
import {UniswapV2Factory} from "@kayen/uniswap-v2-core/contracts/UniswapV2Factory.sol";
import {UniswapV2Router01} from "@kayen/uniswap-v2-periphery/contracts/UniswapV2Router01.sol";
import {SwapRouter} from "@kayen/uniswap-v3-periphery/contracts/SwapRouter.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address wchz = address(0x678c34581db0a7808d0aC669d7025f1408C9a3C6);

        Configuration configuration = new Configuration(address(0xa5B5bE1ecB74696eC27E3CA89E5d940c9dbcCc56));
        PresaleManager presaleManager = new PresaleManager(configuration);
        TokenFactory tokenFactory = new TokenFactory();
        PresalePoolManager presalePoolManager = new PresalePoolManager(configuration, presaleManager);
        UniswapV3Factory poolFactory = new UniswapV3Factory(presalePoolManager);
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
        Quoter quoter = new Quoter(address(poolFactory), wchz);
        UniswapV3PresaleMaker uniswapV3PresaleMaker = new UniswapV3PresaleMaker(
            configuration,
            presaleManager,
            tokenFactory,
            poolFactory,
            positionManager,
            swapRouter,
            quoter,
            wchz
        );
        presalePoolManager.putQuoter(address(quoter));

        vm.stopBroadcast();
    }
}
