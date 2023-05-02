import { ethers } from "hardhat";
import { InternalCallCostsSome, InternalCallCostsSome__factory } from "../typechain-types";
import { expect } from "chai";


describe("InternalCallCostsSome", () => {
    let calledContract: InternalCallCostsSome;
    let callingContract: InternalCallCostsSome;
    let factory: InternalCallCostsSome__factory;
    before(async () => {
        factory = await ethers.getContractFactory("InternalCallCostsSome");
        calledContract = await factory.deploy();
        callingContract = await factory.deploy();
    });

    it("should give some big gas amount when use called from calling", async () => {
        const txWithInternalCall = await callingContract.outerCall(calledContract.address);
        const receiptWithInternalCall = await calledContract.provider.getTransactionReceipt(txWithInternalCall.hash);
        const gasUsedWithInternalCall = receiptWithInternalCall.gasUsed;

        const txWithoutInternalCall = await callingContract.outerCallButWithNoActualCall(calledContract.address);
        const receiptWithoutInternalCall = await calledContract.provider.getTransactionReceipt(txWithoutInternalCall.hash);
        const gasUsedWithoutInternalCall = receiptWithoutInternalCall.gasUsed;
        expect(gasUsedWithInternalCall).greaterThan(gasUsedWithoutInternalCall.mul(10));
    });
});
