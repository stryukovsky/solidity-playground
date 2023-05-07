//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract DelegateCall {
    uint256 public stateVariable;

    event AskedForStateVariable(uint256 value);

    constructor(uint256 _stateVariable) {
        stateVariable = _stateVariable;
    }

    function delegateCall(address delegate) external returns(uint256) {
        (bool status,  bytes memory data) = delegate.delegatecall(abi.encodeWithSignature("getStateSlot()"));
        require(status);
        return uint256(bytes32(data));
    }


    function getStateSlot() public{    
        emit AskedForStateVariable(stateVariable);
    }
}
