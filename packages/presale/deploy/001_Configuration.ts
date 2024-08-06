import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const FEE_VAULT_ADDRESS = "0xb9dF4BD9d3103cF1FB184BF5e6b54Cf55de81747";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const configuration = await deploy("Configuration", {
    from: deployer,
    args: [FEE_VAULT_ADDRESS],
  });

  console.log(`Configuration is deployed(${configuration.address})`);
};

func.tags = ["part1"];

export default func;
