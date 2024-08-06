// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {INonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {PositionValue} from "@kayen/uniswap-v3-periphery/contracts/libraries/PositionValue.sol";
import {IUniswapV3Pool} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "./Presale.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDistributor} from "../distributor/IDistributor.sol";
import {Configuration} from "../Configuration.sol";
import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/IQuoter.sol";

contract UniswapV3Presale is Presale {
    INonfungiblePositionManager positionManager;
    uint256 private tokenId;
    ISwapRouter private swapRouter;
    IQuoter private quoter;

    function initialize(
        ISwapRouter _swapRouter,
        INonfungiblePositionManager _positionManager,
        IQuoter _quoter,
        uint256 _tokenId,
        PresaleInfo memory info,
        Configuration config
    ) external {
        super._initialize(config, info);
        swapRouter = _swapRouter;
        positionManager = _positionManager;
        quoter = _quoter;
        tokenId = _tokenId;
    }

    function getProgress() public view override returns (uint256) {
        PositionInfo memory positionInfo = getPositionInfo();
        uint256 raisedAmount = getRaisedAmount();
        return (1e6 * raisedAmount) / _info.amountToRaise;
    }

    function getRaisedAmount() public view override returns (uint256) {
        PositionInfo memory positionInfo = getPositionInfo();
        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(_info.pool).slot0();
        (uint256 reserve0, uint256 reserve1) = PositionValue.total(
            positionManager,
            tokenId,
            sqrtPriceX96
        );
        if (positionInfo.token0 != _info.token) {
            return reserve0;
        } else {
            return reserve1;
        }
    }

    function _beforeDistribute(uint256 deadline) internal override returns (address, address, uint160) {
        PositionInfo memory positionInfo = getPositionInfo();
        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(_info.pool).slot0();
        burnPosition(deadline);
        return (positionInfo.token0, positionInfo.token1, sqrtPriceX96);
    }


    function burnPosition(uint256 deadline) internal {
        PositionInfo memory position = getPositionInfo();
        positionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams(
                tokenId,
                position.liquidity,
                0,
                0,
                deadline
            )
        );
        positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        positionManager.burn(tokenId);
    }

    function getPositionInfo() public view returns (PositionInfo memory) {
        (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = positionManager.positions(tokenId);
        return
            PositionInfo(
                nonce,
                operator,
                token0,
                token1,
                fee,
                tickLower,
                tickUpper,
                liquidity,
                feeGrowthInside0LastX128,
                feeGrowthInside1LastX128,
                tokensOwed0,
                tokensOwed1
            );
    }

    struct PositionInfo {
        uint96 nonce;
        address operator;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }
}
