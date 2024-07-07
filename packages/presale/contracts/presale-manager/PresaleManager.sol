// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../presale/IPresale.sol";
import "../Configuration.sol";

contract PresaleManager is Ownable {
    mapping(address => IPresale) public presales;
    Configuration config;

    constructor(Configuration _config) Ownable() {
        config = _config;
    }
    function register(IPresale presale) external {
        require(config.presaleMakers(msg.sender), "PresaleManager: FORBIDDEN");
        (address tokenAddress, string memory name, string memory symbol, uint256 totalSupply) = presale.tokenInfo();
        IPresale.PresaleInfo memory presaleInfo =  presale.info();
        presales[tokenAddress] = presale;
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

    function getPresale(address token) external view returns (IPresale) {
        return presales[token];
    }

    function getProgress(address tokenAddress) public view returns (uint256) {
        return presales[tokenAddress].getProgress();
    }

    function isBondingCurveEnd(address tokenAddress) public view returns (bool) {
        return presales[tokenAddress].isBondingCurveEnd();
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
