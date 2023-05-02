//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract CompareExternalPublic {

    function publicFunction(uint256 a, uint256 b) public returns(uint256){
        a + b;
    }

    function externalFunction(uint256 a, uint256 b) external returns(uint256){
        a + b;
    }
}
