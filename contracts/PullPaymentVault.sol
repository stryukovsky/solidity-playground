//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/utils/escrow/Escrow.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract PullPaymentVault is PullPayment, Context {
    
    IERC20 acceptedToken;
    uint256 price;

    constructor(IERC20 _acceptedToken, uint256 _price) payable {
        acceptedToken = _acceptedToken;
        price = _price;
    }

    function buyETH(uint256 amount) public {
        address user = _msgSender();
        address vault = address(this);
        require(acceptedToken.allowance(user, vault) >= amount, "INSUFFICIENT_ALLOWANCE");
        uint256 nativeAccruedToUser = amount / price;
        require(vault.balance >= nativeAccruedToUser);
        acceptedToken.transferFrom(user, vault, amount);
        _asyncTransfer(user, nativeAccruedToUser);
    }
}
