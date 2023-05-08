//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract SignatureERC20 is EIP712 {
    string _name;
    string _version;
    string _symbol;

    uint256 _totalSupply;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => uint256) _nonces;

    bytes32 public constant ACTION_ALLOW = keccak256("ACTION_ALLOW");
    bytes32 public constant ACTION_TRANSACT = keccak256("ACTION_TRANSACT");

    bytes32 STRUCT_TYPEHASH = keccak256(
            "SignatureERC20Action(address from,address to,uint256 value,bytes32 action,uint256 nonce,uint256 deadline)");

    constructor(address vault, uint256 initialSupply, string memory __name, string memory __version, string memory __symbol) EIP712(__name, __version) {
        _name = __name;
        _version = __version;
        _symbol = __symbol;
        _mint(vault, initialSupply);
    }

    function _mint(address to, uint256 value) internal {
        _balances[to] += value;
        _totalSupply += value;
    }

    function domainSeparatorV4() public view returns(bytes32) {
        return _domainSeparatorV4();
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _getDigest(address from, address to, uint256 value, bytes32 action, uint256 nonce, uint256 deadline) private view returns (bytes32) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(STRUCT_TYPEHASH, from, to, value, action, nonce, deadline)));
        return digest;
    }

    function _authorize(
        address from,
        address to,
        uint256 value,
        bytes32 action,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s) internal view{
            require(block.timestamp <= deadline, "EXPIRED");
            bytes32 digest = _getDigest(from, to, value, action, _nonces[from], deadline);
            address signatureRecovered = ecrecover(digest, v, r, s);
            require(signatureRecovered == from, "UNAUTHORIZED");
        }

    function allow(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        _authorize(owner, spender, value, ACTION_ALLOW, deadline, v, r, s);
        _allowances[owner][spender] += value;
        _nonces[owner] += 1;
    }

    function transact(
        address from,
        address to,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        _authorize(from, to, value, ACTION_TRANSACT, deadline, v, r, s);
        require(_balances[from] >= value, "INSUFFICIENT_FUNDS");
        _balances[from] -= value;
        _balances[to] += value;
        _nonces[from] += 1;
    }

    function getNonce(address user) public view returns(uint256) {
        return _nonces[user];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function version() public view returns (string memory) {
        return _version;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint256) {
        return 18;
    }
}
