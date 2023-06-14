import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { NFTAdminTransfer } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("NFTAdminTransfer", () => {
    let contract: NFTAdminTransfer;
    let owner: SignerWithAddress;
    let stranger: SignerWithAddress;

    before(async () => {
        contract = await (await ethers.getContractFactory("NFTAdminTransfer")).deploy();
        [owner, stranger] = await ethers.getSigners();
    });

    const tokenId = 1;
    it("should allow mint from admin", async () => {
        await contract.mint(stranger.address, tokenId);
    });

    it("should revert an attempt to transfer token from non-admin", async () => {
        const attempt = contract.connect(stranger).transferFrom(stranger.address, owner.address, tokenId);
        await expect(attempt).to.be.revertedWith("AccessControl: account 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 is missing role 0x6ef6c12113840e73bf704de56ef147ea7406477154c3d8cfa0b9d1a47c607472");
    });

    it("should give allowance to admin so admin can manually transfer from non-admin via transferFrom()", async () => {
        await contract.connect(stranger).approve(owner.address, tokenId);
    });

    it("should perform a transfer with transferFrom() with admin as a signer", async () => {
        const tx = await contract.connect(owner).transferFrom(stranger.address, owner.address, tokenId);
        await tx.wait();
        const ownerOfToken = await contract.ownerOf(tokenId);
        expect(ownerOfToken).eq(owner.address);
    });
});
