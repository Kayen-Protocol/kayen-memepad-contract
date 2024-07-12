import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const configuration = await deployments.get("Configuration");
  const presaleManager = await deployments.get("PresaleManager");
  const presalePoolManager = await deploy("PresalePoolManager", {
    from: deployer,
    args: [configuration.address, presaleManager.address],
  });

  console.log(`PresalePoolManager is deployed(${presalePoolManager.address})`);
};

func.tags = ["mainnet", "testnet"];

export default func;
