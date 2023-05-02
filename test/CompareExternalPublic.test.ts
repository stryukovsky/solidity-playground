import { expect } from "chai";
import { ethers } from "hardhat";
import { CompareExternalPublic, CompareExternalPublic__factory } from "../typechain-types";

describe("CompareExternalPublic", function () {
    let contractFactory: CompareExternalPublic__factory;
    let contract: CompareExternalPublic;

    before(async () => {
        contractFactory = await ethers.getContractFactory("CompareExternalPublic");
        contract = await contractFactory.deploy();
    });

    it("should give the same gas prices for external and public functions", async () => {
        const txPublic = await contract.publicFunction(1, 1);
        await txPublic.wait();
        const receiptPublic = await contract.provider.getTransactionReceipt(txPublic.hash);
        const gasPublic = receiptPublic.gasUsed;

        const txExternal = await contract.externalFunction(1, 1);
        await txExternal.wait();
        const receiptExternal = await contract.provider.getTransactionReceipt(txExternal.hash);
        const gasExternal = receiptExternal.gasUsed;
        expect(gasPublic).approximately(gasExternal, gasPublic.add(gasExternal).div(2).div(100));
    });
});
