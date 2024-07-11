// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.12;
pragma abicoder v2;

import "../Setup.sol";

import "../mocks/MockPresale.sol";

contract PresaleManagerTest is Setup {
    function test_should_not_allow_non_presale_maker_to_create_presale() public {
        MockPresale presale = new MockPresale();
        vm.startPrank(user1);
        {
            vm.expectRevert();
            presaleManager.register(presale);
        }
        vm.stopPrank();
    }

    function test_should_successfully_register_presale() public {
        vm.startPrank(deployer);
        {
            configuration.putPresaleMaker(user);
        }
        vm.stopPrank();

        MockPresale presale = new MockPresale();
        IPresale.PresaleInfo memory presaleInfo = presale.info();
        (address token, string memory name, string memory symbol, uint256 totalSupply) = presale.tokenInfo();

        vm.startPrank(user);
        {
            presaleManager.register(presale);
        }
        vm.stopPrank();

        assertTrue(address(presaleManager.getPresale(token)) == address(presale));
        assertTrue(presaleManager.getProgress(token) == presale.getProgress());
        assertTrue(presaleManager.isBondingCurveEnd(token) == presale.isBondingCurveEnd());

        presale.setBondingCurveEnd();
        assertTrue(presaleManager.isBondingCurveEnd(token) == presale.isBondingCurveEnd());
    }
}
