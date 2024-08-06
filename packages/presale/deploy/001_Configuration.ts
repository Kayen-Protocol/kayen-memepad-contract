import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { FEE_VAULT_ADDRESS, WCHZ } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const configuration = await deploy("Configuration", {
    from: deployer,
    args: [FEE_VAULT_ADDRESS],
  });

  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  if (!(await configurationContract.paymentTokenWhitelist(WCHZ))) {
    const tx1 = await configurationContract.allowTokenForPayment(WCHZ);
    await tx1.wait();
  }

  console.log(`Configuration is deployed(${configuration.address})`);
};

func.tags = ["part1"];

export default func;
