//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MintableERC20 is ERC20, Ownable {

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol){
        _mint(_msgSender(), initialSupply);
    }

    function mint(address to, uint256 value)public onlyOwner {
        _mint(to, value);
    }
}
