// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Example is ERC1155 {

    constructor() ERC1155("uri://") {
           
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) public {
        _mintBatch(to, ids, amounts, data);
    }
}
