// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import {IPresale} from "../../contracts/presale/IPresale.sol";
import {IDistributor} from "../../contracts/distributor/IDistributor.sol";

contract MockPresale is IPresale {
    bool _isEnd = false;
    
    function tokenInfo() external override returns (address, string memory, string memory, uint256) {
        return (
            address(1),
            "Mock",
            "MOCK",
            100e18
        );
    }

    function isEnd() external override view returns (bool) {
        return _isEnd;
    }

    function getProgress() external override view returns (uint256) {
        return 10;
    }

    function isBondingCurveEnd() external override view returns (bool) {
        return _isEnd;
    }

    function distribute(IDistributor distributor, bytes calldata data) external override {

    }
    function info() external view override returns (PresaleInfo memory) {
        return (
            PresaleInfo(
                address(1),
                address(1),
                address(1),
                address(1),
                100e18,
                100e18,
                "data",
                0,
                false,
                0,
                true
            )
        );
    }

    function setBondingCurveEnd() external {
        _isEnd = true;
    }

}