import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const tokenFactory = await deploy("TokenFactory", {
    from: deployer,
    args: [],
  });

  console.log(`TokenFactory is deployed(${tokenFactory.address})`);
};

func.tags = ["part1"];

export default func;
