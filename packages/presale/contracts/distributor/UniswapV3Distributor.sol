// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "forge-std/console.sol";

import {Configuration} from "../Configuration.sol";
import {Distributor} from "./Distributor.sol";

import {INonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {UniswapV2Library} from "@kayen/uniswap-v2-periphery/contracts/libraries/UniswapV2Library.sol";
import {IUniswapV3Factory} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {TickMath} from "@kayen/uniswap-v3-core/contracts/libraries/TickMath.sol";
import {IUniswapV3Pool} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IQuoter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/IQuoter.sol";

import {LiquidityAmounts} from "@kayen/uniswap-v3-periphery/contracts/libraries/LiquidityAmounts.sol";
import {TickMath} from "@kayen/uniswap-v3-core/contracts/libraries/TickMath.sol";

contract UniswapV3Distributor is Distributor {
    IUniswapV3Factory factory;
    INonfungiblePositionManager positionManager;
    uint256 maxPriceDiffRatio = 5e16;
    IQuoter quoter;

    constructor(
        Configuration _config,
        IUniswapV3Factory _factory,
        INonfungiblePositionManager _positionManager,
        IQuoter _quoter
    ) Distributor(_config) {
        factory = _factory;
        positionManager = _positionManager;
        quoter = _quoter;
    }

    function _doDistribute(
        address token0,
        address token1,
        uint256 expectedPriceZeroToOne,
        bytes calldata data
    ) internal override {
        (uint160 sqrtPriceX96, uint24 fee) = abi.decode(data, (uint160, uint24));

        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);

        IERC20 tokenAInstance = IERC20(tokenA);
        IERC20 tokenBInstance = IERC20(tokenB);

        uint256 tokenABalance = tokenAInstance.balanceOf(address(this));
        uint256 tokenBBalance = tokenBInstance.balanceOf(address(this));

        if (factory.getPool(tokenA, tokenB, fee) == address(0)) {
            factory.createPool(tokenA, tokenB, fee, 0);
        }

        address poolAddress = factory.getPool(tokenA, tokenB, fee);
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

        (uint160 currentSqrtPriceX96, , , , , , ) = pool.slot0();
        if (currentSqrtPriceX96 > 0) {
            uint256 price = quoter.quoteExactInputSingle(tokenA, tokenB, fee, 10 ** ERC20(tokenA).decimals(), 0);
            uint256 pad = 10 ** ERC20(tokenB).decimals();
            uint256 diffRatio = expectedPriceZeroToOne > price
                ? (pad * expectedPriceZeroToOne) / price
                : (pad * price) / expectedPriceZeroToOne;
            require(diffRatio <= maxPriceDiffRatio, "UniswapV2Distributor: price too low");
        } else {
            pool.initialize(sqrtPriceX96);
        }

        tokenAInstance.approve(address(positionManager), tokenABalance);
        tokenBInstance.approve(address(positionManager), tokenBBalance);
        int24 tickSpacing = pool.tickSpacing();

        positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: tokenA,
                token1: tokenB,
                fee: fee,
                tickLower: TickMath.MIN_TICK - (TickMath.MIN_TICK % tickSpacing),
                tickUpper: TickMath.MAX_TICK - (TickMath.MAX_TICK % tickSpacing),
                amount0Desired: tokenABalance,
                amount1Desired: tokenBBalance,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 10
            })
        );
    }
}
