import { utils } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const WCHZ = "0x678c34581db0a7808d0aC669d7025f1408C9a3C6";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const poolFactory = await deployments.get("UniswapV3Factory");
  const descriptor = await deploy("NonfungibleTokenPositionDescriptor", {
    from: deployer,
    args: [WCHZ, utils.formatBytes32String("WCHZ")],
  });
  console.log(`NonfungibleTokenPositionDescriptor is deployed(${descriptor.address})`);

  const positionManager = await deploy("NonfungiblePositionManager", {
    from: deployer,
    args: [poolFactory.address, WCHZ, descriptor.address],
  });
  console.log(`NonfungiblePositionManager is deployed(${positionManager.address})`);

  const swapRouter = await deploy("SwapRouter", {
    from: deployer,
    args: [poolFactory.address, WCHZ],
  });
  console.log(`SwapRouter is deployed(${swapRouter.address})`);

  const quoter = await deploy("Quoter", {
    from: deployer,
    args: [poolFactory.address, WCHZ],
  });

  console.log(`Quoter is deployed(${quoter.address})`);
};

func.tags = ["part2"];

export default func;