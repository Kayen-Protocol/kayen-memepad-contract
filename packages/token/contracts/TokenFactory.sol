// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./CommonToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TokenFactory {
    CommonToken public implementation;

    constructor() {
        implementation = new CommonToken();
    }

    function create(string memory name, string memory symbol, uint256 totalSupply) external returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), abi.encodeCall(implementation.initialize, (name, symbol, totalSupply)));
        CommonToken token = CommonToken(address(proxy));
        token.transferOwnership(msg.sender);
        token.transfer(msg.sender, token.balanceOf(address(this)));
        return address(proxy);
    }

}