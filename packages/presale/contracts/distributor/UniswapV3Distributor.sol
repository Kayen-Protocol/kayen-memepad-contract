// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {Configuration} from "../Configuration.sol";
import {Distributor} from "./Distributor.sol";

import {INonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {UniswapV2Library} from "@kayen/uniswap-v2-periphery/contracts/libraries/UniswapV2Library.sol";
import {IUniswapV3Factory} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {TickMath} from "@kayen/uniswap-v3-core/contracts/libraries/TickMath.sol";
import {IUniswapV3Pool} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {LiquidityAmounts} from "@kayen/uniswap-v3-periphery/contracts/libraries/LiquidityAmounts.sol";
import {TickMath} from "@kayen/uniswap-v3-core/contracts/libraries/TickMath.sol";

contract UniswapV3Distributor is Distributor {
    using SafeERC20 for IERC20;

    uint24 fee = 100;
    IUniswapV3Factory immutable factory;
    INonfungiblePositionManager immutable positionManager;

    constructor(
        Configuration _config,
        IUniswapV3Factory _factory,
        INonfungiblePositionManager _positionManager
    ) Distributor(_config) {
        factory = _factory;
        positionManager = _positionManager;
    }

    function getPoolAddress(address token0, address token1) external returns (address) {
        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);
        if (factory.getPool(tokenA, tokenB, fee) == address(0)) {
            factory.createPool(token0, token1, fee);
        }
        return address(factory.getPool(tokenA, tokenB, fee));
    }

    function _doDistribute(
        address token0,
        address token1,
        uint160 sqrtPriceX96,
        uint256 deadline
    ) internal override {

        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);

        IERC20 tokenAInstance = IERC20(tokenA);
        IERC20 tokenBInstance = IERC20(tokenB);

        uint256 tokenABalance = tokenAInstance.balanceOf(address(this));
        uint256 tokenBBalance = tokenBInstance.balanceOf(address(this));

        if (factory.getPool(tokenA, tokenB, fee) == address(0)) {
            factory.createPool(tokenA, tokenB, fee);
        }

        address poolAddress = factory.getPool(tokenA, tokenB, fee);
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

        uint256 liquidity = pool.liquidity();
        require(liquidity == 0, "UniswapV3Distributor: pool already has liquidity");
        pool.initialize(sqrtPriceX96);

        tokenAInstance.forceApprove(address(positionManager), tokenABalance);
        tokenBInstance.forceApprove(address(positionManager), tokenBBalance);

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
                deadline: deadline
            })
        );
    }
}
