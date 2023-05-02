//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract InternalCallCostsSome {
    uint256 stateVariable = 1000;

    function outerCall(address calledContract) public {
        bytes memory calldataForContract = abi.encodeWithSignature("innerCall()");
        calledContract.call(calldataForContract);
    }

    function outerCallButWithNoActualCall(address calledContract) public {
        bytes memory calldataForContract = abi.encodeWithSignature("innerCall()");
    }

    function innerCall() public view returns(uint256) {
        for(uint256 i = 0; i < stateVariable; i++) {
            
        }
        return stateVariable;
    }
}
