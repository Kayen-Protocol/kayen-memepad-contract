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
  
  const nonce = await ethers.provider.getTransactionCount(deployer);
  console.log("Current nonce:", nonce);

  // 원하는 논스 값 (예: 100)
  const targetNonce = 50;
  
  // 현재 논스가 목표 논스보다 작은 경우에만 실행
  if (nonce < targetNonce) {
    console.log(`Initializing nonce from ${nonce} to ${targetNonce}`);
    
    // 더미 트랜잭션을 보내서 논스 증가
    for (let i = nonce; i < targetNonce; i++) {
      const tx = await signer.sendTransaction({
        to: deployer,
        value: 1,
        nonce: i,
        gasPrice: 2600000000000, // 기본 가스 가격의 120%
        gasLimit: 30000 // 기본 전송에 필요한 가스 한도
      });
      console.log(`Processed nonce: ${i}`);
      await tx.wait();
      // 트랜잭션이 마이닝될 때까지 잠시 대기
    //   await new Promise(resolve => setTimeout(resolve, 500));
    }
  }
};

func.tags = ["XXX_nonce"];
export default func;
