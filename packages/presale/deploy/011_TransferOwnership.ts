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
  const presalePoolManagerTx = await presalePoolManagerContract.putQuoter(quoter.address);
  await presalePoolManagerTx.wait();
  const presalePoolManagerOwnershipTx = await presalePoolManagerContract.transferOwnership(owner);
  await presalePoolManagerOwnershipTx.wait();
  console.log("Ownership transferred to multisig");

  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  const configurationTx = await configurationContract.transferOwnership(owner);
  await configurationTx.wait();
  console.log("Ownership transferred to multisig");

  const presaleManager = await deployments.get("PresaleManager");
  const presaleManagerContract = new ethers.Contract(presaleManager.address, presaleManager.abi, signer);
  const presaleManagerTx = await presaleManagerContract.transferOwnership(owner);
  await presaleManagerTx.wait();
  console.log("Ownership transferred to multisig");

};

func.tags = ["transferOwnership"];

export default func;
