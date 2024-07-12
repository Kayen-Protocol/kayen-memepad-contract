import { utils } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const WCHZ = "0x678c34581db0a7808d0aC669d7025f1408C9a3C6";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const presalePoolManager = await deployments.get("PresalePoolManager");
  const poolFactory = await deploy("UniswapV3Factory", {
    from: deployer,
    args: [presalePoolManager.address],
  });

  const descriptor = await deploy("NonfungibleTokenPositionDescriptor", {
    from: deployer,
    args: [WCHZ, utils.formatBytes32String("WCHZ")],
  });

  const positionManager = await deploy("NonfungiblePositionManager", {
    from: deployer,
    args: [poolFactory.address, WCHZ, descriptor.address],
  });

  const swapRouter = await deploy("SwapRouter", {
    from: deployer,
    args: [poolFactory.address, WCHZ],
  });

  const quoter = await deploy("Quoter", {
    from: deployer,
    args: [poolFactory.address, WCHZ],
  });

  console.log(`UniswapV3Factory is deployed(${poolFactory.address})`);
  console.log(`NonfungibleTokenPositionDescriptor is deployed(${descriptor.address})`);
  console.log(`NonfungiblePositionManager is deployed(${positionManager.address})`);
  console.log(`SwapRouter is deployed(${swapRouter.address})`);
  console.log(`Quoter is deployed(${quoter.address})`);
};

func.tags = ["mainnet", "testnet"];

export default func;
