import { HardhatUserConfig } from "hardhat/config";

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-deploy";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-dependency-compiler";

require("hardhat-contract-sizer");

export const config: HardhatUserConfig = {
  paths: {
    sources: "./contracts",
  },
  dependencyCompiler: {
    paths: [
      "@kayen/uniswap-v3-core/contracts/UniswapV3Factory.sol",
      "@kayen/uniswap-v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol",
      "@kayen/uniswap-v3-periphery/contracts/NonfungiblePositionManager.sol",
      "@kayen/uniswap-v3-periphery/contracts/SwapRouter.sol",
      "@kayen/uniswap-v3-periphery/contracts/lens/Quoter.sol",
    ],
  },
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    overrides: {},
  },
  mocha: {
    timeout: 100000000,
  },
  networks: {
    neoxt4: {
      url: "https://testnet.rpc.banelabs.org",
      chainId: 12227332,
      accounts: require("./secrets.json").privateKey,
      tags: ["testnet"],
      saveDeployments: true,
      gasPrice: 40000000000,
    },
    chiliz: {
      url: "https://rpc.ankr.com/chiliz/5747708213d21767e4c9839a5930bf488b64e93d2311bdc24125a570a2da1479",
      chainId: 88888,
      accounts: require("./secrets.json").privateKey,
      tags: ["chiliz_mainnet"],
      saveDeployments: true,
    },
    chiliz_spicy: {
      url: "https://spicy-rpc.chiliz.com",
      chainId: 88882,
      accounts: require("./secrets.json").privateKey,
      tags: ["spicy_testnet"],
      saveDeployments: true,
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/cwlARYWEEACYbZYUWyBeQ5TrKhwPvbXk",
      chainId: 11155111,
      accounts: require("./secrets.json").privateKey,
      tags: ["eth_testnet"],
      saveDeployments: true,
    },
    story_odyssey: {
      url: "https://odyssey.storyrpc.io",
      chainId: 1516,
      accounts: require("./secrets.json").privateKey,
      tags: ["stroy_testnet"],
      saveDeployments: true,
    },
  },
  namedAccounts: {
    deployer: { default: 0 },
  },
};

export default config;
