// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import "../Setup.sol";

contract ConfigurationTest is Setup {
    
    function test_configuration() public {
        Configuration configuration = new Configuration(feeVault);
        assertTrue(configuration.owner() == address(this));
        
        address target = address(0x5123);
        
        configuration.putPresaleMaker(target);
        assertTrue(configuration.presaleMakers(target));
        
        configuration.removePresaleMaker(target);
        assertTrue(!configuration.presaleMakers(target));
        
        configuration.allowTokenForPayment(target);
        assertTrue(configuration.paymentTokenWhitlist(target));
        
        configuration.disallowTokenForPayment(target);
        assertTrue(!configuration.paymentTokenWhitlist(target));
        
        configuration.allowDistributor(target);
        assertTrue(configuration.distributorWhitelist(target));
        
        configuration.disallowDistributor(target);
        assertTrue(!configuration.distributorWhitelist(target));
        
        assertTrue(configuration.isDistributorWhitelisted(target) == false);

        configuration.putDefaultDistributionFeeRate(100);
        assertTrue(configuration.defaultDistributionFeeRate() == 100);

        configuration.putDistributionFeeRateForToken(target, 200);
        assertTrue(configuration.getDistributionFeeRate(target, address(0)) == 200);

        configuration.putFeeVault(target);
        assertTrue(configuration.feeVault() == target);

        configuration.putMintingFee(1e18);
        assertTrue(configuration.mintingFee() == 1e18);
        
        // 2%
        configuration.putDefaultTradeFee(1e6 / 50);
        assertTrue(configuration.defaultTradeFee() == 1e6 / 50);

        configuration.putTradeFeeForToken(target, 1e6 / 100);
        assertTrue(configuration.getTradeFee(target, address(0)) == 1e6 / 100);
    }
}