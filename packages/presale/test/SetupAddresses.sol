pragma solidity >=0.6.12;
pragma abicoder v2;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {MockERC20} from "./mocks/MockERC20.sol";
import {WETH9} from "./mocks/WETH9.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {SwapRouter} from "@kayen/uniswap-v3-periphery/contracts/SwapRouter.sol";
import {UniswapV3Pool} from "@kayen/uniswap-v3-core/contracts/UniswapV3Pool.sol";
import {TokenFactory} from "@kayen/token/contracts/TokenFactory.sol";
import {UniswapV3Factory} from "@kayen/uniswap-v3-core/contracts/UniswapV3Factory.sol";
import {NonfungiblePositionManager} from "@kayen/uniswap-v3-periphery/contracts/NonfungiblePositionManager.sol";
import {NonfungibleTokenPositionDescriptor} from "@kayen/uniswap-v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";
import {Quoter} from "@kayen/uniswap-v3-periphery/contracts/lens/Quoter.sol";
import {UniswapV2Factory} from "@kayen/uniswap-v2-core/contracts/UniswapV2Factory.sol";
import {UniswapV2Router01} from "@kayen/uniswap-v2-periphery/contracts/UniswapV2Router01.sol";

import {UniswapV2Distributor} from "../contracts/distributor/UniswapV2Distributor.sol";
import {UniswapV3Distributor} from "../contracts/distributor/UniswapV3Distributor.sol";
import {Configuration} from "../contracts/Configuration.sol";
import {PresaleManager} from "../contracts/presale-manager/PresaleManager.sol";
import {UniswapV3PresaleMaker} from "../contracts/presale/UniswapV3PresaleMaker.sol";

contract SetupAddresses is Test {
    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    WETH9 weth;
    ERC20 bera;

    address user;
    address user1;
    address user2;

    address feeVault;
    address deployer;

    Configuration configuration;
    PresaleManager presaleManager;
    TokenFactory tokenFactory;
    UniswapV3Factory poolFactory;
    SwapRouter swapRouter;
    NonfungiblePositionManager positionManager;
    UniswapV3PresaleMaker uniswapV3PresaleMaker;
    UniswapV2Distributor uniswapV2Distributor;
    UniswapV3Distributor uniswapV3Distributor;
    Quoter externalV3Quoter;

    UniswapV3Factory externalV3Factory;
    NonfungiblePositionManager externalV3PositionManager;
    SwapRouter externalV3SwapRouter;

    UniswapV2Factory externalV2Factory;
    UniswapV2Router01 externalV2SwapRouter;


    function setupAddresses() internal {
        deployer = address(0x9f661e30ee1017591b6Fe3308007b21441Ca0c0b);

        user = address(0x5123);
        user1 = address(0x5123 + 1);
        user2 = address(0x5123 + 2);
        feeVault = address(0x5123 + 3);

        vm.startPrank(deployer);
        {
            weth = new WETH9();
            bera = new MockERC20("BERA", "BERA", 1000000000e18);

            configuration = new Configuration(feeVault);
            presaleManager = new PresaleManager(configuration);
            tokenFactory = new TokenFactory();
            poolFactory = new UniswapV3Factory(configuration);
            NonfungibleTokenPositionDescriptor tokenDescriptor = new NonfungibleTokenPositionDescriptor(address(weth), bytes32("WETH"));
            positionManager = new NonfungiblePositionManager(address(poolFactory), address(weth), address(tokenDescriptor));
            swapRouter = new SwapRouter(address(poolFactory), address(weth));
            uniswapV3PresaleMaker = new UniswapV3PresaleMaker(configuration, presaleManager, tokenFactory, poolFactory, positionManager, swapRouter, address(weth));

            NonfungibleTokenPositionDescriptor tokenDescriptor2 = new NonfungibleTokenPositionDescriptor(address(weth), bytes32("WETH"));
            externalV3Factory = new UniswapV3Factory(configuration);
            externalV3PositionManager = new NonfungiblePositionManager(address(externalV3Factory), address(weth), address(tokenDescriptor2));
            externalV3SwapRouter = new SwapRouter(address(externalV3Factory), address(weth));
            externalV3Quoter = new Quoter(address(externalV3Factory), address(weth));

            externalV2Factory = new UniswapV2Factory(deployer);
            externalV2SwapRouter = new UniswapV2Router01(address(externalV2Factory), address(weth));

            uniswapV2Distributor = new UniswapV2Distributor(configuration, externalV2Factory, externalV2SwapRouter);
            uniswapV3Distributor = new UniswapV3Distributor(configuration, externalV3Factory, externalV3PositionManager, externalV3Quoter);
        }
        vm.stopPrank();

        _setUserLabel();
        _setContractLabel();
        _setKeeperLabel();
        _setTokenLabel();
    }

    function _setUserLabel() private {
        vm.label(user, "USER");
        vm.label(user1, "USER1");
        vm.label(user2, "USER2");
    }

    function _setContractLabel() private {
        // Contract label
    }

    function _setKeeperLabel() private {
        vm.label(deployer, "Deployer");
    }

    function _setTokenLabel() private {
        // Token label
        vm.label(address(weth), "WETH");
        vm.label(address(bera), "BERA");
    }
}
