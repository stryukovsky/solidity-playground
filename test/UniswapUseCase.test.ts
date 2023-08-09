import { ethers } from "hardhat";
import { SimpleSwap } from "../typechain-types";
import { BigNumber, Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

const WETH_ABI = [
    "function balanceOf(address owner) view returns (uint256)",
    "function transfer(address to, uint amount) returns (bool)",
    "function deposit() public payable",
    "function approve(address spender, uint256 amount) returns (bool)",
  ];
  


describe("Uniswap usage case", () => {
    let contractExample: SimpleSwap;
    let weth: Contract;
    let signer: SignerWithAddress;

    before(async () => {
        contractExample = await (await ethers.getContractFactory("SimpleSwap")).deploy("0xE592427A0AEce92De3Edee1F18E0157C05861564") as SimpleSwap;
        weth = await ethers.getContractAt(WETH_ABI, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
        [signer] = await ethers.getSigners();
    });

    const depositValue = ethers.utils.parseEther("5.0");
    it("should prepare WETH for a swap", async () => {
        await weth.functions.deposit({value: depositValue});
        const balance = await weth.functions.balanceOf(await signer.getAddress());
        expect(balance[0]).greaterThanOrEqual(depositValue);
    });

    it("should approve WETH for contract", async () => {
        await weth.functions.approve(contractExample.address, depositValue);
    });

    it("should perform a swap WETH to DAI", async () => {
        await contractExample.swapWETHForDAI(ethers.utils.parseEther("1"));
    });
})
