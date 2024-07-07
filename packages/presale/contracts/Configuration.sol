// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IPoolConfiguration} from "@kayen/uniswap-v3-core/contracts/interfaces/IPoolConfiguration.sol";

contract Configuration is IPoolConfiguration, Ownable {
    mapping(address => bool) public paymentTokenWhitlist;
    mapping(address => bool) public distributorWhitelist;
    mapping(address => bool) public presaleMakers;
    mapping(address => bool) public isPoolPaused;
    bool public isAllPoolPaused;

    address public feeVault;

    uint24 public defaultDistributionFeeRate = 1e6 / 100; // 0.01 = 1%
    mapping(address => uint24) public distributionFeeRate;

    // amount of payment token as minting fee
    uint256 public mintingFee = 0;

    uint24 public defaultTradeFee = 1e6 / 100; // 0.01 = 1%
    mapping(address => uint24) public tradeFee;

    uint24 public maxTreasuryRate = 8e5; // 80%

    constructor(address _feeVault) {
        feeVault = _feeVault;
    }

    function putPresaleMaker(address presaleMaker) external onlyOwner {
        presaleMakers[presaleMaker] = true;
    }

    function removePresaleMaker(address presaleMaker) external onlyOwner {
        presaleMakers[presaleMaker] = false;
    }

    function allowTokenForPayment(address token) external onlyOwner {
        paymentTokenWhitlist[token] = true;
    }

    function disallowTokenForPayment(address token) external onlyOwner {
        paymentTokenWhitlist[token] = false;
    }

    function allowDistributor(address distributor) external onlyOwner {
        distributorWhitelist[distributor] = true;
    }

    function disallowDistributor(address distributor) external onlyOwner {
        distributorWhitelist[distributor] = false;
    }

    function isDistributorWhitelisted(address distributor) external view returns (bool) {
        return distributorWhitelist[distributor];
    }

    function putDefaultDistributionFeeRate(uint24 feeRate) external onlyOwner {
        defaultDistributionFeeRate = feeRate;
    }

    function putDistributionFeeRateForToken(address token, uint24 feeRate) external onlyOwner {
        distributionFeeRate[token] = feeRate;
    }

    function getDistributionFeeRate(address token0, address token1) external view returns (uint24) {
        uint24 fee0 = distributionFeeRate[token0];
        uint24 fee1 = distributionFeeRate[token1];
        if(fee0 == 0 && fee1 == 0) {
            return defaultDistributionFeeRate;
        }
        return fee0 > fee1 ? fee0 : fee1;
    }

    function putFeeVault(address vault) external onlyOwner {
        require(vault != address(0), "Configuration: fee vault cannot be zero address");
        feeVault = vault;
    }

    function getFeeVault() external view returns (address) {
        return feeVault;
    }

    function isPaused(address pool) override external view returns (bool) {
        return isPoolPaused[pool] || isPausedAll();
    }

    function isPausedAll() override public view returns (bool) {
        return isAllPoolPaused;
    }

    function pause(address pool) external onlyOwner {
        isPoolPaused[pool] = true;
    }

    function unpause(address pool) external onlyOwner {
        isPoolPaused[pool] = false;
    }

    function pauseAll() external onlyOwner {
        isAllPoolPaused = true;
    }

    function unpauseAll() external onlyOwner {
        isAllPoolPaused = false;
    }

    function putMintingFee(uint256 fee) external onlyOwner {
        mintingFee = fee;
    }
    
    function putDefaultTradeFee(uint24 _tradeFee) external onlyOwner {
        assertTradeFee(_tradeFee);
        defaultTradeFee = _tradeFee;
    }

    function putTradeFeeForToken(address token, uint24 _tradeFee) external onlyOwner {
        assertTradeFee(_tradeFee);
        tradeFee[token] = _tradeFee;
    }

    function getTradeFee(address token0, address token1) override external view returns (uint24) {
        uint24 fee0 = tradeFee[token0];
        uint24 fee1 = tradeFee[token1];
        if(fee0 == 0 && fee1 == 0) {
            return defaultTradeFee;
        }
        return fee0 > fee1 ? fee0 : fee1;
    }

    function putMaxTreasuryRate(uint24 rate) external onlyOwner {
        require(rate <= 1e6, "Configuration: max treasury rate must be less than 1e6");
        maxTreasuryRate = rate;
    }

    function getMaxTreasuryRate() external view returns (uint24) {
        return maxTreasuryRate;
    }

    function assertTradeFee(uint24 _tradeFee) internal view {
        // max 2%
        require(_tradeFee <= 1e6 / 50, "Configuration: trade fee must be less than 1%");
    }

    function assertDistributeFee(uint24 _tradeFee) internal view {
        // max 2%
        require(_tradeFee <= 1e6 / 50, "Configuration: trade fee must be less than 1%");
    }

}