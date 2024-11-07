// export const V2_FACOTRY = "0xfc1924E20d64AD4daA3A4947b4bAE6cDE77d2dBC";
// export const V2_ROUTER = "0xb82b0e988a1FcA39602c5079382D360C870b44c8";

import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { getNetworkAddresses } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);
  const { chainId } = await ethers.provider.getNetwork();
  
  const { V2_FACTORY, V2_ROUTER } = getNetworkAddresses(chainId);

  const configuration = await deployments.get("Configuration");
  const distributor = await deploy("UniswapV2Distributor", {
    from: deployer,
    args: [configuration.address, V2_FACTORY, V2_ROUTER],
  });

  const contract = new ethers.Contract(configuration.address, configuration.abi, signer);

  const prevDefaultDistributor = await contract.defaultDistributor();
  console.log(prevDefaultDistributor);
  if (prevDefaultDistributor !== distributor.address) {
    const tx1 = await contract.allowDistributor(distributor.address);
    await tx1.wait();
    const tx2 = await contract.putDefaultDistributor(distributor.address);
    await tx2.wait();
  }

  console.log("UniswapV2Distributor", distributor.address);
};

func.tags = ["v2Distributor"];

export default func;
