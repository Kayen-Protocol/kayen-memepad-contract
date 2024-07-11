// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../presale/IPresale.sol";
import "../Configuration.sol";

contract PresaleManager is Ownable {
    mapping(address => bool) public isRegistered;
    mapping(address => address) public presales;
    mapping(address => address) public presalesByPool;
    Configuration config;

    constructor(Configuration _config) Ownable() {
        config = _config;
    }

    function register(IPresale presale) external {
        require(config.presaleMakers(msg.sender), "PresaleManager: FORBIDDEN");
        (address tokenAddress, string memory name, string memory symbol, uint256 totalSupply) = presale.tokenInfo();
        require(!isRegistered[tokenAddress], "PresaleManager: ALREADY_REGISTERED");
        IPresale.PresaleInfo memory presaleInfo =  presale.info();
        presales[tokenAddress] = address(presale);
        isRegistered[tokenAddress] = true;
        presalesByPool[presaleInfo.pool] = address(presale);
        emit PresaleCreated(
            name,
            symbol,
            tokenAddress,
            presaleInfo.paymentToken,
            presaleInfo.pool,
            presaleInfo.amountToRaise,
            totalSupply,
            presaleInfo.amountToSale,
            presaleInfo.data
        );
    }

    function isPending(address target) external view returns (bool) {
        IPresale presale = getPresale(target);
        return presale.info().startTimestamp > block.timestamp;
    }

    function getPresale(address target) public view returns (IPresale) {
        if(address(presales[target]) == address(0)) {
            return IPresale(presalesByPool[target]);
        }
        return IPresale(presales[target]);
    }

    function getProgress(address target) public view returns (uint256) {
        return getPresale(target).getProgress();
    }

    function isBondingCurveEnd(address target) public view returns (bool) {
        return getPresale(target).isBondingCurveEnd();
    }


    event PresaleCreated(
        string name,
        string symbol,
        address token,
        address paymentToken,
        address pairAddress,
        uint256 presaleAmount,
        uint256 totalSupply,
        uint256 saleAmount,
        string data
    );
}
