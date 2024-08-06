import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const configuration = await deployments.get("Configuration");
  const presaleManager = await deploy("PresaleManager", {
    from: deployer,
    args: [configuration.address],
  });

  console.log(`PresaleManager is deployed(${presaleManager.address})`);
};

func.tags = ["part1"];

export default func;
