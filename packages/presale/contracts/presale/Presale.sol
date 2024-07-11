// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {CommonToken} from "@kayen/token/contracts/CommonToken.sol";

import "./IPresale.sol";
import {ERC721Receiver} from "../libraries/ERC721Receiver.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IDistributor} from "../distributor/IDistributor.sol";
import {Configuration} from "../Configuration.sol";

abstract contract Presale is IPresale, ERC721Receiver, Initializable {
    PresaleInfo internal _info;
    Configuration internal _config;

    function _initialize(Configuration config, PresaleInfo memory info) internal initializer {
        _info = info;
        _config = config;
    }

    function tokenInfo() public virtual returns (address, string memory, string memory, uint256) {
        ERC20 tokenInstance = ERC20(_info.token);
        return (_info.token, tokenInstance.name(), tokenInstance.symbol(), tokenInstance.totalSupply());
    }

    function isEnd() external view override returns (bool) {
        return _info.isEnd;
    }

    function info() public view override returns (PresaleInfo memory) {
        return _info;
    }

    function getProgress() public view virtual returns (uint256);

    function isBondingCurveEnd() public view returns (bool) {
        return getProgress() >= 100;
    }

    function _beforeDistribute() internal virtual returns (address, address, uint256);

    function distribute(IDistributor distributor, bytes calldata data) external override onlyAuthorized {
        require(isBondingCurveEnd(), "Presale: bonding curve not end");
        require(_config.isDistributorWhitelisted(address(distributor)), "Presale: distributor not whitelisted");

        (address token0, address token1, uint256 expectedPriceZeroToOne) = _beforeDistribute();
        sendDistributionFee();
        sendToTreasury(token0, token1);

        if (_info.isNewToken) {
            CommonToken(_info.token).removeBlacklist();
            ERC20(token0).transfer(address(distributor), ERC20(token0).balanceOf(address(this)));
            ERC20(token1).transfer(address(distributor), ERC20(token1).balanceOf(address(this)));
            distributor.distribute(token0, token1, expectedPriceZeroToOne, data);
        } else {
            ERC20(token0).transfer(address(_info.minter), ERC20(token0).balanceOf(address(this)));
            ERC20(token1).transfer(address(_info.minter), ERC20(token1).balanceOf(address(this)));
        }

        _info.isEnd = true;

        emit Distributed();
    }

    function sendToTreasury(address token0, address token1) internal {
        if (_info.toTreasuryRate == 0) {
            return;
        }
        uint256 token0Amount = (ERC20(token0).balanceOf(address(this)) * _info.toTreasuryRate) / 1e6;
        uint256 token1Amount = (ERC20(token1).balanceOf(address(this)) * _info.toTreasuryRate) / 1e6;
        if (token0Amount > 0) {
            ERC20(token0).transfer(_info.minter, token0Amount);
        }
        if (token1Amount > 0) {
            ERC20(token1).transfer(_info.minter, token1Amount);
        }
    }

    function sendDistributionFee() internal {
        uint256 rate = _config.getDistributionFeeRate(_info.token, _info.paymentToken);
        if (rate == 0) {
            return;
        }
        uint256 amount1 = (ERC20(_info.paymentToken).balanceOf(address(this)) * rate) / 1e6;
        if (amount1 > 0) {
            ERC20(_info.paymentToken).transfer(_config.feeVault(), amount1);
        }

        uint256 amount2 = (ERC20(_info.token).balanceOf(address(this)) * rate) / 1e6;
        if (amount2 > 0) {
            ERC20(_info.token).transfer(_config.feeVault(), amount2);
        }
    }

    modifier onlyAuthorized() {
        require(msg.sender == _info.minter || msg.sender == _config.owner(), "Presale: not authorized");
        _;
    }
}
