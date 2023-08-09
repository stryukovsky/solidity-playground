// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StorageStructs {
    struct Payment {
        uint256 startsAt;
        uint256 endsAt;
        uint256 amountUSD;
        uint256 nonce;
    }

    struct PaymentOptimized {
        uint64 startsAt;
        uint64 endsAt;
        uint64 amountUSD;
        uint64 nonce;
    }

    mapping(address => Payment) payments;
    mapping(address => PaymentOptimized) paymentsOptimized;

    function addPaymentOptimized(uint64 startsAt, uint64 endsAt, uint64 amountUSD, uint64 nonce) public {
        paymentsOptimized[msg.sender] = PaymentOptimized({
            startsAt: startsAt,
            endsAt: endsAt,
            amountUSD: amountUSD,
            nonce: nonce
        });
    }

    function addPayment(uint256 startsAt, uint256 endsAt, uint256 amountUSD, uint256 nonce) public {
        payments[msg.sender] = Payment({
            startsAt: startsAt,
            endsAt: endsAt,
            amountUSD: amountUSD,
            nonce: nonce
        });
    }
}
