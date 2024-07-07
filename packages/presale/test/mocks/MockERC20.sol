// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 totalSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, totalSupply);
    }
}
