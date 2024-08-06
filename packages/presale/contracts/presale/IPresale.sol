// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import {IDistributor} from "../distributor/IDistributor.sol";

interface IPresale {
    function tokenInfo() external returns (address, string memory, string memory, uint256);
    function getProgress() external view returns (uint256);
    function getRaisedAmount() external view returns (uint256);
    function isBondingCurveEnd() external view returns (bool);
    function distribute(IDistributor distributor, uint256 deadline) external;
    function info() external view returns (PresaleInfo memory);
    function isEnd() external view returns (bool);
    function isExpired() external view returns (bool);

    struct PresaleInfo {
        address minter;
        address token;
        address pool;

        address paymentToken;
        uint256 amountToRaise;

        uint256 amountToSale;
        string data;

        // 1e6 => 100%;
        uint24 toTreasuryRate;

        bool isEnd;
        uint256 startTimestamp;
        bool isNewToken;
    }

    event Distributed();
}