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
import {UniswapV2Distributor} from "../contracts/distributor/UniswapV2Distributor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Distribute is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address test1Token = address(0x50E21e7c696bfdE12ae2A1ee0F627F7E3C9Ea0D5);
        address test2Token = address(0x8Dbe110E3f19f5C840e9Ee10e9887DfD234f777F);
        UniswapV2Distributor uniswapV2Distributor = UniswapV2Distributor(
            address(0x2ae3d5567651F6fB7FF61863CA4F7c9E0f277CFE)
        );
        // IERC20(test1Token).transfer(address(uniswapV2Distributor), IERC20(test1Token).balanceOf(address(this)));
        // IERC20(test2Token).transfer(address(uniswapV2Distributor), IERC20(test2Token).balanceOf(address(this)));
        uniswapV2Distributor.distribute(address(test1Token), address(test2Token), 0, block.timestamp + 1000);

        vm.stopBroadcast();
    }
}
