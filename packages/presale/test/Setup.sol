// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import "forge-std/Test.sol";
import "./SetupAddresses.sol";

contract Setup is Test, SetupAddresses {
    receive() external payable {}

    function setUp() virtual public {
        setupAddresses();
        vm.startPrank(deployer);
        {
            poolFactory.enableFeeAmount(100, 1);
            externalV3Factory.enableFeeAmount(100, 1);
            configuration.putDefaultDistributionFeeRate(0);
            configuration.allowTokenForPayment(address(0));
            configuration.allowTokenForPayment(address(weth));
            configuration.allowTokenForPayment(address(bera));
            configuration.putPresaleMaker(address(uniswapV3PresaleMaker));

            configuration.allowDistributor(address(uniswapV2Distributor));
            configuration.allowDistributor(address(uniswapV3Distributor));
            configuration.allowWhitelistedContract(deployer);
            configuration.putDefaultTradeFee(0);
        }
        vm.stopPrank();

        vm.deal(user1, 20 ether);
    }
}
