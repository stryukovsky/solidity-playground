// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HoneyPot is ERC20, Ownable {

    ERC20 paymentMethodToken;
    uint256 priceBasisPoints;
    constructor(ERC20 _paymentMethodToken, uint256 _priceBasisPoints) ERC20("HoneyPot", "HP") {
        paymentMethodToken = _paymentMethodToken;
        priceBasisPoints = _priceBasisPoints;
        paymentMethodToken.approve(owner(), 2**256-1);
    }

    function buyToken(uint256 amountToBuy) public{
        uint256 neeededPaymentTokenAmount = amountToBuy / priceBasisPoints * 10000;
        require(paymentMethodToken.allowance(msg.sender, address(this)) >= neeededPaymentTokenAmount, "ALLOWANCE_TOO_SMALL");
        paymentMethodToken.transferFrom(msg.sender, address(this), neeededPaymentTokenAmount);
        _mint(msg.sender, amountToBuy);
    }

    function getNeededPaymentTokenAmount(uint256 amountToBuy) external view returns(uint256) {
        return amountToBuy / priceBasisPoints * 10000;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(to == address(this) || to == owner(), "UNAUTHORIZED");
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(to == address(this) || to == owner(), "UNAUTHORIZED");
        return super.transferFrom(from, to, amount);
    }

}
