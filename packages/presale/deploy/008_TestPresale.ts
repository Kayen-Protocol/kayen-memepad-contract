import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const WCHZ = "0x678c34581db0a7808d0aC669d7025f1408C9a3C6";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const configuration = await deployments.get("Configuration");
  const configurationContract = new ethers.Contract(configuration.address, configuration.abi, signer);
  if (!(await configurationContract.paymentTokenWhitlist(WCHZ))) {
    const tx1 = await configurationContract.allowTokenForPayment(WCHZ);
    await tx1.wait();
  }

  const v3PresaleMaker = await deployments.get("UniswapV3PresaleMaker");
  const contract = new ethers.Contract(v3PresaleMaker.address, v3PresaleMaker.abi, signer);
  const tx = await contract.startWithNewToken(
    WCHZ,
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
    ""
  );
  await tx.wait();

  console.log(`V3PresaleMaker is deployed(${v3PresaleMaker.address})`);
};

func.tags = ["test"];

export default func;
