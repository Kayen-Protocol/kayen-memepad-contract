// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {CommonToken} from "@kayen/token/contracts/CommonToken.sol";

import "./IPresale.sol";
import {ERC721Receiver} from "../libraries/ERC721Receiver.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IDistributor} from "../distributor/IDistributor.sol";
import {Configuration} from "../Configuration.sol";

abstract contract Presale is IPresale, ERC721Receiver, Initializable {
    using SafeERC20 for ERC20;
    
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
        return getProgress() >= 1e6;
    }

    function isExpired() public view override returns (bool) {
        return block.timestamp > _info.startTimestamp + _config.maxPresaleDuration();
    }

    function _beforeDistribute(uint256 deadline) internal virtual returns (address, address, uint160);

    function canDistribute(address distributor) external view override returns (bool) {
        return isBondingCurveEnd() && IDistributor(distributor).canDistribute(_info.token, _info.paymentToken);
    }

    function distribute(address distributor, uint256 deadline) external override {
        require(distributor == _config.defaultDistributor() || msg.sender == _info.minter || msg.sender == _config.owner(), "Presale: not authorized");
        require(isBondingCurveEnd() || isExpired(), "Presale: bonding curve not end");
        require(_config.isDistributorWhitelisted(distributor), "Presale: distributor not whitelisted");

        (address token0, address token1, uint160 sqrtPriceX96) = _beforeDistribute(deadline);
        uint256 balance0 = ERC20(token0).balanceOf(address(this));
        uint256 balance1 = ERC20(token1).balanceOf(address(this));

        sendDistributionFee(token0, token1, balance0, balance1);
        sendToTreasury(token0, token1, balance0, balance1);

        if (_info.isNewToken) {
            CommonToken(_info.token).removeBlacklist();
            ERC20(token0).safeTransfer(distributor, ERC20(token0).balanceOf(address(this)));
            ERC20(token1).safeTransfer(distributor, ERC20(token1).balanceOf(address(this)));
            IDistributor(distributor).distribute(token0, token1, sqrtPriceX96, deadline);
        } else {
            ERC20(token0).safeTransfer(_info.minter, ERC20(token0).balanceOf(address(this)));
            ERC20(token1).safeTransfer(_info.minter, ERC20(token1).balanceOf(address(this)));
        }

        _info.isEnd = true;

        emit Distributed();
    }

    function sendToTreasury(address token0, address token1, uint256 balance0, uint256 balance1) internal {
        if (_info.toTreasuryRate == 0) {
            return;
        }
        uint256 token0Amount = (balance0 * _info.toTreasuryRate) / 1e6;
        uint256 token1Amount = (balance1 * _info.toTreasuryRate) / 1e6;
        if (token0Amount > 0) {
            ERC20(token0).safeTransfer(_info.minter, token0Amount);
        }
        if (token1Amount > 0) {
            ERC20(token1).safeTransfer(_info.minter, token1Amount);
        }
    }

    function sendDistributionFee(address token0, address token1, uint256 balance0, uint256 balance1) internal {
        uint256 rate = _config.getDistributionFeeRate(_info.token, _info.paymentToken);
        if (rate == 0) {
            return;
        }
        if (balance0 > 0) {
            uint256 amount1 = (balance0 * rate) / 1e6;
            ERC20(token0).safeTransfer(_config.feeVault(), amount1);
        }

        if (balance1 > 0) {
            uint256 amount2 = (balance1 * rate) / 1e6;
            ERC20(token1).safeTransfer(_config.feeVault(), amount2);
        }
    }
}
