// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import { Configuration } from "./Configuration.sol";
import { PresaleManager } from "./presale-manager/PresaleManager.sol";
import { IPoolConfiguration } from "@kayen/uniswap-v3-core/contracts/interfaces/IPoolConfiguration.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract PresalePoolManager is IPoolConfiguration, Ownable {
    Configuration config;
    PresaleManager manager;
    address quoter;

    constructor(Configuration _config, PresaleManager _manager) Ownable() {
        config = _config;
        manager = _manager;
    }

    function getTradeFee(address token0, address token1) external view returns (uint24) {
        return config.getTradeFee(token0, token1);
    }

    function getFeeVault() external view returns (address) {
        return config.getFeeVault();
    }

    function beforeSwap(address pool, address recipient) external {
        if(recipient != quoter) {
            require(!checkIsPaused(pool), "PresalePoolManager: Pool is paused");
            require(!manager.isBondingCurveEnd(pool), "PresalePoolManager: Bonding curve end");
            require(!checkIsPending(pool), "PresalePoolManager: Pool is pending");
        }
    }

    function isWhitelistedMaker(address maker) external view returns (bool) {
        return config.presaleMakers(maker);
    }

    function putQuoter(address _quoter) external onlyOwner {
        quoter = _quoter;
    }

    function checkIsPending(address pool) private view returns (bool) {
        return manager.isPending(pool);
    }

    function checkIsPaused(address pool) private view returns (bool) {
        return config.isPaused(pool);
    }


}