import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const WCHZ = "0x678c34581db0a7808d0aC669d7025f1408C9a3C6";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const presaleManager = await deployments.get("PresaleManager");
  const presaleManagerContract = new ethers.Contract(presaleManager.address, presaleManager.abi, signer);

  const swapRouter = await deployments.get("SwapRouter");
  const swapRouterContract = new ethers.Contract(swapRouter.address, swapRouter.abi, signer);

  let idx = 0;
  do {
    let token;
    try {
      const presaleAddress = await presaleManagerContract.allPresales(idx);
      idx += 1;
      const presale = await ethers.getContractAt("Presale", presaleAddress);
      const info = await presale.info();
      token = info.token;
    } catch {
      break;
    }
    try {
      const swapTx = await swapRouterContract.exactInput(
        {
          path: ethers.utils.solidityPack(["address", "uint24", "address"], [WCHZ, 100, token]),
          recipient: deployer,
          deadline: ethers.constants.MaxUint256,
          amountIn: ethers.utils.parseEther("1"),
          amountOutMinimum: 0,
        },
        { value: ethers.utils.parseEther("1") }
      );
      await swapTx.wait();
    } catch {}
  } while (true);
};

func.tags = ["test:swap"];

export default func;