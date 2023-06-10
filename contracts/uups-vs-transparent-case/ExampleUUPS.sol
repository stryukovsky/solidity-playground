// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ExampleUUPS is UUPSUpgradeable, OwnableUpgradeable {

    function initialize() public initializer {
        __Ownable_init();
    }
    

    function _authorizeUpgrade(address) internal virtual override onlyOwner {}
}
