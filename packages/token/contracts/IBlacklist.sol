// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

interface IBlacklist {
    function isTransferBlacklisted(address target) external view returns (bool);
}