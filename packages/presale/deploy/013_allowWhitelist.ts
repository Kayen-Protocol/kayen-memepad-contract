import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  const tx = await configurationContract.allowWhitelistedContract("0xa48dd2af7c4c1a01ecda61bdf1157e06ef9ae93e");
  await tx.wait();
};

func.tags = ["allowWhitelist"];

export default func;
