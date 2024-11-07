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
    chiliz_spicy: {
      url: "https://spicy-rpc.chiliz.com",
      chainId: 88882,
      accounts: require("./secrets.json").privateKey,
      tags: ["mainnet"],
      saveDeployments: true,
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/cwlARYWEEACYbZYUWyBeQ5TrKhwPvbXk",
      chainId: 11155111,
      accounts: require("./secrets.json").privateKey,
      tags: ["eth_testnet"],
      saveDeployments: true,
    },

  },
  namedAccounts: {
    deployer: { default: 0 },
  },
};

export default config;
