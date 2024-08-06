import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const presalePoolManager = await deployments.get("PresalePoolManager");
  const poolFactory = await deploy("UniswapV3Factory", {
    from: deployer,
    args: [presalePoolManager.address],
  });

  const contract = new ethers.Contract(poolFactory.address, poolFactory.abi, signer);

  const tx = await contract.enableFeeAmount(100, 1);
  await tx.wait();
  const initCodeHash = await contract.callStatic.POOL_INIT_CODE_HASH();

  console.log(`UniswapV3Factory is deployed(${poolFactory.address})`);
  console.log("INIT_CODE_HASH", initCodeHash);
};

func.tags = ["part1"];

export default func;
