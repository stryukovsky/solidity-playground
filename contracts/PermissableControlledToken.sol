//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";

contract PermissableControlledToken is ERC20, AccessControl {
    bytes32 public constant TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    string _version;
    bytes32 public DOMAIN_SEPARATOR;

    mapping(address => uint256) nonces;

    constructor(
        address admin,
        string memory name,
        string memory symbol,
        string memory initialVersion,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _mint(admin, initialSupply);
        _version = initialVersion;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(initialVersion)),
                block.chainid,
                address(this)
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(owner != address(0), "Bad owner");
        require(deadline > block.timestamp, "Expired");
        uint nonce = nonces[owner];
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TYPEHASH, owner, spender, value, nonce, deadline))
            )
        );
        address signatureRecovered = ecrecover(digest, v, r, s);
        require(signatureRecovered == owner, "Bad signature");
        _approve(owner, spender, value);
        nonces[owner]++;
    }

    function getNonce(address owner) public view returns (uint256) {
        return nonces[owner];
    }

    function version() public view returns (string memory) {
        return _version;
    }
}
