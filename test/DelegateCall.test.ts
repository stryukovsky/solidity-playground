import { ethers } from "hardhat";
import { DelegateCall, DelegateCall__factory } from "../typechain-types";
import { expect } from "chai";

describe("DelegateCall", () => {
    let called: DelegateCall;
    let calling: DelegateCall;
    let factory: DelegateCall__factory;

    const valueInProxy = 2;
    const valueInImpl = 1;
    before(async () => {
        factory = await ethers.getContractFactory("DelegateCall");
        called = await factory.deploy(valueInImpl);
        calling = await factory.deploy(valueInProxy);
    });

    it("should return value from calling", async () => {
        const tx = await calling.delegateCall(called.address);
        const hash = tx.hash;
        const receipt = await called.provider.getTransactionReceipt(hash);
        const value = Number.parseInt(receipt.logs[0].data.substring(2), 16);
        expect(value).eq(valueInProxy);
        
    });
});
