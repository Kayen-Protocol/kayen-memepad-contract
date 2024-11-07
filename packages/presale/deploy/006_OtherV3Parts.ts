import { utils } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { getNetworkAddresses } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers} = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const { chainId } = await ethers.provider.getNetwork();

  const { wETH } = getNetworkAddresses(chainId);

  const poolFactory = await deployments.get("UniswapV3Factory");
  const descriptor = await deploy("NonfungibleTokenPositionDescriptor", {
    from: deployer,
    args: [wETH, utils.formatBytes32String("wETH")],
  });
  console.log(`NonfungibleTokenPositionDescriptor is deployed(${descriptor.address})`);

  const positionManager = await deploy("NonfungiblePositionManager", {
    from: deployer,
    args: [poolFactory.address, wETH, descriptor.address],
  });
  console.log(`NonfungiblePositionManager is deployed(${positionManager.address})`);

  const swapRouter = await deploy("SwapRouter", {
    from: deployer,
    args: [poolFactory.address, wETH],
  });
  console.log(`SwapRouter is deployed(${swapRouter.address})`);

  const quoter = await deploy("Quoter", {
    from: deployer,
    args: [poolFactory.address, wETH],
  });

  console.log(`Quoter is deployed(${quoter.address})`);
};

func.tags = ["part2"];

export default func;
