// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract SimpleSwap {
    ISwapRouter public immutable swapRouter;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint24 public constant feeTier = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    function swapWETHForDAI(uint256 amountIn) external returns (uint256 amountOut) {
        TransferHelper.safeTransferFrom(WETH, msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(WETH, address(swapRouter), amountIn);
        uint256 minOut = 0;
        uint160 priceLimit = 0; 

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: DAI, 
            fee: feeTier, 
            recipient: msg.sender,
            deadline: block.timestamp, 
            amountIn: amountIn,
            amountOutMinimum: minOut,
            sqrtPriceLimitX96: priceLimit
        });
        amountOut = swapRouter.exactInputSingle(params);
    }
}
