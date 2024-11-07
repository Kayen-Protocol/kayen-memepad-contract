import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { getNetworkAddresses } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);
  const { chainId } = await ethers.provider.getNetwork();

  const { FEE_VAULT_ADDRESS, wETH } = getNetworkAddresses(chainId);

  const configuration = await deploy("Configuration", {
    from: deployer,
    args: [FEE_VAULT_ADDRESS],
  });

  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  if (!(await configurationContract.paymentTokenWhitelist(wETH))) {
    const tx1 = await configurationContract.allowTokenForPayment(wETH);
    await tx1.wait();
  }

  console.log(`Configuration is deployed(${configuration.address})`);
};

func.tags = ["part1"];

export default func;
