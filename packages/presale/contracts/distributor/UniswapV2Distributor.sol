// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {Distributor} from "./Distributor.sol";
import {Configuration} from "../Configuration.sol";

import {IUniswapV2Router01} from "@kayen/uniswap-v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import {UniswapV2Library} from "@kayen/uniswap-v2-periphery/contracts/libraries/UniswapV2Library.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Factory} from "@kayen/uniswap-v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@kayen/uniswap-v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract UniswapV2Distributor is Distributor {
    IUniswapV2Factory factory;
    IUniswapV2Router01 router;
    uint256 maxPriceDiffRatio = 5e16;

    constructor(Configuration _config, IUniswapV2Factory _factory, IUniswapV2Router01 _router) Distributor(_config) {
        factory = _factory;
        router = _router;
    }

    function _doDistribute(address token0, address token1, uint256 expectedPriceZeroToOne, bytes calldata data) internal override {
        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);

        IERC20 tokenAInstance = IERC20(tokenA);
        IERC20 tokenBInstance = IERC20(tokenB);

        uint256 tokenABalance = tokenAInstance.balanceOf(address(this));
        uint256 tokenBBalance = tokenBInstance.balanceOf(address(this));

        address pairAddress = factory.getPair(tokenA, tokenB);
        if (pairAddress != address(0)) {
            IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
            (uint112 reserveA, uint112 reserveB, uint32 blockTimestampLast) = pair.getReserves();

            if (reserveA > 0 || reserveB > 0) {
                uint256 tokenAAmount = 10 ** ERC20(tokenA).decimals();
                uint256 price = UniswapV2Library.getAmountOut(tokenAAmount, reserveA, reserveB);
                uint256 pad = 10 ** ERC20(tokenB).decimals();
                uint256 diffRatio = expectedPriceZeroToOne > price
                    ? (pad * expectedPriceZeroToOne) / price
                    : (pad * price) / expectedPriceZeroToOne;
                require(diffRatio <= maxPriceDiffRatio, "UniswapV2Distributor: price too low");
            }
        }

        tokenAInstance.approve(address(router), tokenABalance);
        tokenBInstance.approve(address(router), tokenBBalance);

        router.addLiquidity(tokenA, tokenB, tokenABalance, tokenBBalance, 0, 0, address(this), block.timestamp + 100);
    }
}
