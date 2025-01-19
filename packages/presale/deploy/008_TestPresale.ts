import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { getNetworkAddresses } from "./constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const { chainId } = await ethers.provider.getNetwork();
  const { wETH } = getNetworkAddresses(chainId);

  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  if (!(await configurationContract.paymentTokenWhitelist(wETH))) {
    const tx1 = await configurationContract.allowTokenForPayment(wETH);
    await tx1.wait();
  }

  const deadline = (await ethers.provider.getBlock("latest")).timestamp + 100000;

  const v3PresaleMaker = await deployments.get("UniswapV3PresaleMaker");
  const contract = new ethers.Contract(v3PresaleMaker.address, v3PresaleMaker.abi, signer);
  const tx = await contract.startWithNewToken(
    deployer,
    wETH,
    "Test MEME",
    "TMEME",
    ethers.utils.parseEther("1000000000"),
    "8678867702397588659397255742442909",
    -345480,
    191220,
    ethers.utils.parseEther("1000000000"),
    ethers.utils.parseEther("10"),
    0,
    0,
    0,
    deadline,
    ""
  );
  await tx.wait();

  console.log(`V3PresaleMaker is deployed(${v3PresaleMaker.address})`);
};

func.tags = ["test"];

export default func;
