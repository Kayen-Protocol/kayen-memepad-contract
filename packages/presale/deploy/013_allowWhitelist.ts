import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  const tx = await configurationContract.allowWhitelistedContract("0x62e27cf0754c57429a01eed56d19bdccbb2c3b82");
  await tx.wait();
};

func.tags = ["allowWhitelist"];

export default func;
