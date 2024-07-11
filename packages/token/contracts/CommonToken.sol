// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IBlacklist.sol";

contract CommonToken is ERC20Upgradeable, OwnableUpgradeable {
    
    struct CommonTokenStorage {
        IBlacklist blacklist;
    }

    bytes32 private constant STORAGE_LOCATION = 0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500;

    function _getCommonTokenStorage() private pure returns (CommonTokenStorage storage $) {
        assembly {
            $.slot := STORAGE_LOCATION
        }
    }

    function _getBlacklist() internal view returns (IBlacklist) {
        CommonTokenStorage storage $ = _getCommonTokenStorage();
        return $.blacklist;
    }

    function initialize(string memory name, string memory symbol, uint256 initialSupply) public virtual initializer {
        __ERC20_init(name, symbol);
        __Ownable_init();
        _mint(_msgSender(), initialSupply);
    }

    function putBlacklist(IBlacklist _blacklist) external onlyOwner {
        CommonTokenStorage storage $ = _getCommonTokenStorage();
        $.blacklist = _blacklist;
    }

    function removeBlacklist() external onlyOwner {
        CommonTokenStorage storage $ = _getCommonTokenStorage();
        $.blacklist = IBlacklist(address(0));
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        IBlacklist blacklist = _getBlacklist();
        require(
            address(blacklist) == address(0) || !blacklist.isTransferBlacklisted(to),
            "CommonToken: to is in blacklist"
        );
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        IBlacklist blacklist = _getBlacklist();
        require(
            address(blacklist) == address(0) || !blacklist.isTransferBlacklisted(to),
            "CommonToken: to is in blacklist"
        );
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
}
