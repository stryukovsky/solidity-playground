// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Categories is ERC1155 {

    uint256 public constant CATEGORY_RESOURCES = 0xff;


    // kind is stored in 5th and 6th bytes counting from the least
    // 0xff|ff|00|00|00|00|
    //    6| 5| 4| 3| 2| 1| 
    uint256 public constant CATEGORY_MASK = 0xffff00000000;

    uint256 public constant CATEGORY_MAX_SUPPLY = 0x0000ffffffff;

    // we define `aaee` as category identifier for resources
    uint256 public constant RESOURCE_CATEGORY = 0xaaee00000000;

    // we define 0xaaee00000001 as wood. Notice that as ID it has resource category identifier in it 
    uint256 public constant RESOURCE_ID_WOOD = RESOURCE_CATEGORY | 0x1;

    // we define 0xaaee0000000a as gold
    uint256 public constant RESOURCE_ID_GOLD = RESOURCE_CATEGORY | 0xa;

    // we define 0xaaee0000000b as silver
    uint256 public constant RESOURCE_ID_SILVER = RESOURCE_CATEGORY | 0xb;

    // we define `beef` as category identifier for playable NFT Character category
    uint256 public constant CHARACTER_CATEGORY = 0xbeef00000000;

    // every time character is minted this counter increases
    uint256 public charactersCount = 0;

    // size in bits of category
    // size means amount of bits before the category identifier
    // counting from the least bit
    // in out case, since identifier is in 5th and 6th bytes, 
    // the size is 4 bytes before these two ones.
    // 4 bytes store 4 * 8 = 32 bits
    // every category can contain upto 4294967295 token ids (2 ^ 32 - 1) in it
    // this is sufficient for almost every dApp
    uint256 public constant CATEGORY_SIZE = 4 * 8;

    constructor () ERC1155("some://uri:1000") {

    }

    function getCategory(uint256 tokenId) public pure returns(uint256) {
        return tokenId & CATEGORY_MASK;
    }

    function isResource(uint256 tokenId) public pure returns(bool) {
        return getCategory(tokenId) == RESOURCE_CATEGORY;
    }

    function mintResource(address to, uint256 tokenId, uint256 amount) public  {
        require(isResource(tokenId), "NOT_A_RESOURCE");
        _mint(to, tokenId, amount, "");
    }

    function getTokenId(uint256 category, uint256 counter) public pure returns(uint256) {
        require(~CATEGORY_MASK & category == 0, "BAD_CATEGORY: category should have first 4 bytes empty");
        require(counter < 0xffffffff, "BAD_TOKEN_ID: counter overflow");
        return category | counter;
    }

    function mintCharacter(address to) public {
        uint256 tokenId = getTokenId(CHARACTER_CATEGORY, charactersCount);
        _mint(to, tokenId, 1, "");
        charactersCount++;
    }
}
