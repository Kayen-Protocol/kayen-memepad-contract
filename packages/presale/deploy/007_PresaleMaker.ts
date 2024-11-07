import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { WCHZ } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const configuration = await deployments.get("Configuration");
  const presaleManager = await deployments.get("PresaleManager");
  const tokenFactory = await deployments.get("TokenFactory");
  const poolFactory = await deployments.get("UniswapV3Factory");
  const positionManager = await deployments.get("NonfungiblePositionManager");
  const swapRouter = await deployments.get("SwapRouter");
  const quoter = await deployments.get("Quoter");

  const v3PresaleMaker = await deploy("UniswapV3PresaleMaker", {
    from: deployer,
    args: [
      configuration.address,
      presaleManager.address,
      tokenFactory.address,
      poolFactory.address,
      positionManager.address,
      swapRouter.address,
      quoter.address,
      WCHZ,
    ],
  });

  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  const tx = await configurationContract.putPresaleMaker(v3PresaleMaker.address);
  await tx.wait();

  console.log(`V3PresaleMaker is deployed(${v3PresaleMaker.address})`);
};

func.tags = ["part2"];

export default func;
