// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "../Configuration.sol";
import "./IPresale.sol";
import "@kayen/token/contracts/TokenFactory.sol";
import "@kayen/token/contracts/CommonToken.sol";

import {Quoter} from "@kayen/uniswap-v3-periphery/contracts/lens/Quoter.sol";

import {PresaleManager} from "../presale-manager/PresaleManager.sol";
import {UniswapV2Library} from "@kayen/uniswap-v2-periphery/contracts/libraries/UniswapV2Library.sol";
import {UniswapV3Presale} from "./UniswapV3Presale.sol";
import {ERC721Receiver} from "../libraries/ERC721Receiver.sol";

import {ISwapRouter} from "@kayen/uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {LiquidityAmounts} from "@kayen/uniswap-v3-periphery/contracts/libraries/LiquidityAmounts.sol";
import {TickMath} from "@kayen/uniswap-v3-core/contracts/libraries/TickMath.sol";
import {IUniswapV3Pool} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {INonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {IUniswapV3Factory} from "@kayen/uniswap-v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UniswapV3PresaleMaker is ERC721Receiver {
    Configuration public config;
    TokenFactory public tokenFactory;
    UniswapV3Presale public implementation;
    IUniswapV3Factory public poolFactory;
    INonfungiblePositionManager public positionManager;
    PresaleManager public presaleManager;
    ISwapRouter swapRouter;
    Quoter public quoter;
    
    uint24 public poolFee = 100;
    address public weth;

    constructor(
        Configuration _config,
        PresaleManager _presaleManager,
        TokenFactory _tokenFactory,
        IUniswapV3Factory _poolFactory,
        INonfungiblePositionManager _positionManager,
        ISwapRouter _swapRouter,
        Quoter _quoter,
        address _weth
    ) {
        config = _config;
        tokenFactory = _tokenFactory;
        poolFactory = _poolFactory;
        positionManager = _positionManager;
        presaleManager = _presaleManager;
        implementation = new UniswapV3Presale();
        swapRouter = _swapRouter;
        weth = _weth;
        quoter = _quoter;
    }

    function startWithNewToken(
        address paymentToken,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint160 sqrtPriceX96,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountToSale,
        uint256 amountToRaise,
        uint256 amountForBuyInstantly,
        uint24 toTreasuryRate,
        uint256 startTimestamp,
        string memory data
    ) external payable returns (IPresale) {
        address token = tokenFactory.create(name, symbol, totalSupply);
        CommonToken tokenInstance = CommonToken(token);
        tokenInstance.putBlacklist(config);
        uint256 minterAllocation = totalSupply - amountToSale;
        if (minterAllocation > 0) {
            tokenInstance.transfer(msg.sender, minterAllocation);
        }
        return
            _create(
                true,
                paymentToken,
                token,
                sqrtPriceX96,
                tickLower,
                tickUpper,
                amountToSale,
                amountToRaise,
                amountForBuyInstantly,
                toTreasuryRate,
                startTimestamp,
                data
            );
    }

    function start(
        address paymentToken,
        address saleToken,
        uint160 sqrtPriceX96,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountToSale,
        uint256 amountToRaise,
        uint256 amountForBuyInstantly,
        uint24 toTreasuryRate,
        uint256 startTimestamp,
        string memory data
    ) external payable returns (IPresale) {
        require(
            IERC20(saleToken).transferFrom(msg.sender, address(this), amountToSale),
            "UniswapV3PresaleMaker: transfer failed"
        );
        return
            _create(
                false,
                paymentToken,
                saleToken,
                sqrtPriceX96,
                tickLower,
                tickUpper,
                amountToSale,
                amountToRaise,
                amountForBuyInstantly,
                toTreasuryRate,
                startTimestamp,
                data
            );
    }

    function _create(
        bool isNewToken,
        address paymentToken,
        address saleToken,
        uint160 sqrtPriceX96,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountToSale,
        uint256 amountToRaise,
        uint256 amountForBuyInstantly,
        uint24 toTreasuryRate,
        uint256 startTimestamp,
        string memory data
    ) internal returns (IPresale) {
        require(toTreasuryRate <= config.getMaxTreasuryRate(), "UniswapV3PresaleMaker: treasury rate too high");
        require(config.paymentTokenWhitlist(paymentToken), "UniswapV3PresaleMaker: payment token not whitelisted");
        require(amountToRaise > 0, "UniswapV3PresaleMaker: presale amount must be greater than 0");

        if (weth == paymentToken) {
            require(
                msg.value >= amountForBuyInstantly + config.mintingFee(),
                "UniswapV3PresaleMaker: insufficient fees"
            );
        } else {
            require(msg.value >= config.mintingFee(), "UniswapV3PresaleMaker: insufficient minting fee");
            require(
                amountForBuyInstantly == 0 ||
                    IERC20(paymentToken).transferFrom(msg.sender, address(this), amountForBuyInstantly),
                "UniswapV3PresaleMaker: transfer for buy instantly failed"
            );
        }

        IERC20 tokenInstance = IERC20(saleToken);
        require(tokenInstance.balanceOf(address(this)) >= amountToSale, "UniswapV3PresaleMaker: insufficient balance");
        require(amountToSale > 0, "UniswapV3PresaleMaker: sale amount must be greater than 0");

        (address token0, address token1) = UniswapV2Library.sortTokens(paymentToken, saleToken);
        address pool = poolFactory.createPool(token0, token1, poolFee);
        IUniswapV3Pool(pool).initialize(sqrtPriceX96);

        assertValidParams(
            pool,
            tickLower,
            tickUpper,
            token0 == saleToken ? amountToSale : 0,
            token1 == saleToken ? amountToSale : 0
        );
        tokenInstance.approve(address(positionManager), amountToSale);
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: poolFee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: token0 == saleToken ? amountToSale : 0,
                amount1Desired: token1 == saleToken ? amountToSale : 0,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100
            })
        );

        (
            uint96 _nonce,
            address _operator,
            address _token0,
            address _token1,
            uint24 _fee,
            int24 _tickLower,
            int24 _tickUpper,
            uint128 _liquidity,
            uint256 _feeGrowthInside0LastX128,
            uint256 _feeGrowthInside1LastX128,
            uint128 _tokensOwed0,
            uint128 _tokensOwed1
        ) = positionManager.positions(tokenId);

        IPresale.PresaleInfo memory info = IPresale.PresaleInfo({
            minter: msg.sender,
            token: saleToken,
            pool: pool,
            paymentToken: paymentToken,
            amountToRaise: amountToRaise,
            amountToSale: amountToSale,
            data: data,
            toTreasuryRate: toTreasuryRate,
            isEnd: false,
            startTimestamp: startTimestamp,
            isNewToken: isNewToken
        });

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(implementation.initialize, (swapRouter, positionManager, quoter, tokenId, info, config))
        );
        IPresale presale = IPresale(address(proxy));
        positionManager.transferFrom(address(this), address(presale), tokenId);

        if(isNewToken) {
            CommonToken(saleToken).transferOwnership(address(presale));
        }

        presaleManager.register(presale);

        buyInstantly(saleToken, paymentToken, amountForBuyInstantly);

        return presale;
    }

    function assertValidParams(
        address pool,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) public {
        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(pool).slot0();
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        uint256 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            sqrtRatioAX96,
            sqrtRatioBX96,
            amount0Desired,
            amount1Desired
        );
        require(liquidity > 0, "UniswapV3PresaleMaker: invalid liquidity");
    }

    function buyInstantly(address token, address paymentToken, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        uint256 value = weth == paymentToken ? amount : 0;
        IERC20(token).approve(address(swapRouter), amount);
        uint256 amountOut = swapRouter.exactInput{value: value}(
            ISwapRouter.ExactInputParams(
                abi.encodePacked(paymentToken, poolFee, token),
                address(this),
                block.timestamp + 10,
                amount,
                0
            )
        );
        IERC20(token).transfer(msg.sender, amountOut);
    }
}