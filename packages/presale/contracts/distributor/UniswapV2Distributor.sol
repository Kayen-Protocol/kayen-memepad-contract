// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {Distributor} from "./Distributor.sol";
import {Configuration} from "../Configuration.sol";

import {IUniswapV2Router01} from "@kayen/uniswap-v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import {UniswapV2Library} from "@kayen/uniswap-v2-periphery/contracts/libraries/UniswapV2Library.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Factory} from "@kayen/uniswap-v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@kayen/uniswap-v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract UniswapV2Distributor is Distributor {
    using SafeERC20 for IERC20;

    IUniswapV2Factory immutable factory;
    IUniswapV2Router01 immutable router;

    constructor(Configuration _config, IUniswapV2Factory _factory, IUniswapV2Router01 _router) Distributor(_config) {
        factory = _factory;
        router = _router;
    }

    function getPoolAddress(address token0, address token1) external returns (address) {
        return UniswapV2Library.pairFor(address(factory), token0, token1);
    }

    function canDistribute(address token0, address token1) public view override returns (bool) {
        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);

        address pairAddress = factory.getPair(tokenA, tokenB);
        if (pairAddress != address(0)) {
            IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
            (uint112 reserveA, uint112 reserveB, uint32 blockTimestampLast) = pair.getReserves();
            return reserveA == 0 && reserveB == 0;
        }

        return true;
    }

    function _doDistribute(address token0, address token1, uint160 sqrtXPrice96, uint256 deadline) internal override {
        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);

        IERC20 tokenAInstance = IERC20(tokenA);
        IERC20 tokenBInstance = IERC20(tokenB);

        uint256 tokenABalance = tokenAInstance.balanceOf(address(this));
        uint256 tokenBBalance = tokenBInstance.balanceOf(address(this));

        // require(canDistribute(token0, token1), "UniswapV2Distributor: pair already has liquidity");

        tokenAInstance.forceApprove(address(router), tokenABalance);
        tokenBInstance.forceApprove(address(router), tokenBBalance);

        router.addLiquidity(tokenA, tokenB, tokenABalance, tokenBBalance, 0, 0, address(this), deadline);
    }
}
