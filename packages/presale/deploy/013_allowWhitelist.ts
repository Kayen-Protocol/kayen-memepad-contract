import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  const tx = await configurationContract.allowWhitelistedContract("0xf419974c881137f042d790bd1c85ce51801f7674");
  await tx.wait();
};

func.tags = ["allowWhitelist"];

export default func;
