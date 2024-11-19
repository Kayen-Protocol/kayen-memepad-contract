import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { getNetworkAddresses } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);
  const { chainId } = await ethers.provider.getNetwork();
  const { owner } = getNetworkAddresses(chainId);

  const quoter = await deployments.get("Quoter");
  const presalePoolManager = await deployments.get("PresalePoolManager");
  const presalePoolManagerContract = new ethers.Contract(presalePoolManager.address, presalePoolManager.abi, signer);


  // Validate PresalePoolManager owner
  const presalePoolManagerOwner = await presalePoolManagerContract.owner();
  if (presalePoolManagerOwner.toLowerCase() !== owner.toLowerCase()) {
    throw new Error(`Invalid PresalePoolManager owner. Expected ${owner}, got ${presalePoolManagerOwner}`);
  }
  console.log("PresalePoolManager ownership validated");

  // Validate Configuration owner
  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  const configurationOwner = await configurationContract.owner();
  if (configurationOwner.toLowerCase() !== owner.toLowerCase()) {
    throw new Error(`Invalid Configuration owner. Expected ${owner}, got ${configurationOwner}`);
  }
  console.log("Configuration ownership validated");

  // Validate PresaleManager owner
  const presaleManager = await deployments.get("PresaleManager");
  const presaleManagerContract = new ethers.Contract(presaleManager.address, presaleManager.abi, signer);
  const presaleManagerOwner = await presaleManagerContract.owner();
  if (presaleManagerOwner.toLowerCase() !== owner.toLowerCase()) {
    throw new Error(`Invalid PresaleManager owner. Expected ${owner}, got ${presaleManagerOwner}`);
  }
  console.log("PresaleManager ownership validated");

};

func.tags = ["validation"];

export default func;
