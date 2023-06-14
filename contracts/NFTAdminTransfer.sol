// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract NFTAdminTransfer is ERC721, AccessControl {

    bytes32 public constant TRANSFERS_ADMIN_ROLE  = keccak256("TRANSFERS_ADMIN_ROLE");

    constructor() ERC721("NFTAdminable", "ADM") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFERS_ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }

    function mint(address to, uint256 tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, tokenId);
        if (tokenId < 16) {
            _approve(msg.sender, tokenId);
        }
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual override {
        if (tokenId < 16) {
            require(hasRole(TRANSFERS_ADMIN_ROLE, msg.sender));
        }
        super._safeTransfer(from, to, tokenId, data);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override{
        if (tokenId < 16) {
            require(hasRole(TRANSFERS_ADMIN_ROLE, msg.sender));
        }
        super._transfer(from, to, tokenId);
    }

}
