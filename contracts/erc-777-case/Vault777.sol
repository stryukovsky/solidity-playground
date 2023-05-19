// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC777Recipient} from "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";

contract Vault777 is Ownable, IERC777Recipient {
    IERC20 public token;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 public constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    mapping(address => uint256) public withdrawable;

    address public contractAddress;

    constructor(IERC20 _token) {
        token = _token;
        contractAddress = address(this);
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    function tokensReceived(
        address,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bytes calldata
    ) external {
        require(to == contractAddress, "BAD_RECIPIENT");
        withdrawable[from] += amount;
    }

    function withdraw() external {
        require(address(this) == contractAddress, "DELEGATECALL_PROHIBITED");
        withdrawable[msg.sender] = 0;
        token.transfer(msg.sender, withdrawable[msg.sender]);
    }
}
