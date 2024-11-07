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

    function canDistribute(address token0, address token1) public view override returns (bool) {
        return true;
    }

    function _doDistribute(address token0, address token1, uint160 sqrtPriceX96, uint256 deadline) internal override {
        (address tokenA, address tokenB) = UniswapV2Library.sortTokens(token0, token1);

        uint256 tokenABalance = IERC20(tokenA).balanceOf(address(this));
        uint256 tokenBBalance = IERC20(tokenB).balanceOf(address(this));

        positionManager.createAndInitializePoolIfNecessary(tokenA, tokenB, fee, sqrtPriceX96);

        IERC20(tokenA).forceApprove(address(positionManager), tokenABalance);
        IERC20(tokenB).forceApprove(address(positionManager), tokenBBalance);

        int24 tickSpacing = 1;
        int24 tickLower = TickMath.MIN_TICK - (TickMath.MIN_TICK % tickSpacing);
        int24 tickUpper = TickMath.MAX_TICK - (TickMath.MAX_TICK % tickSpacing);

        positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: tokenA,
                token1: tokenB,
                fee: fee,
                tickLower: tickLower,
                tickUpper: tickUpper,
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
