import { ethers } from "hardhat";
import { PermissableControlledToken, PermissableControlledToken__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { _TypedDataEncoder } from "ethers/lib/utils";
import { TypedDataDomain, TypedDataField } from "ethers";
import { expect } from "chai";


describe("PermissableControlledToken", () => {

    let contract: PermissableControlledToken;
    let factory: PermissableControlledToken__factory;
    let admin: SignerWithAddress;
    let owner: SignerWithAddress;
    let spender: SignerWithAddress;

    const version = "1.0";
    const name = "Tether USD";
    const symbol = "USDT";
    const value = ethers.utils.parseEther("100");
    const initialSupply = ethers.utils.parseEther("100000");
    before(async () => {
        const signers = await ethers.getSigners();
        admin = signers[0];
        owner = signers[1];
        spender = signers[2];
        factory = await ethers.getContractFactory("PermissableControlledToken") as PermissableControlledToken__factory;
        contract = await factory.deploy(admin.address, name, symbol, version, initialSupply);
    });

    const chainId = 31337;

    let domain: TypedDataDomain
    it("should have proper domain hash", async () => {
        domain = {
            name,
            version,
            chainId,
            verifyingContract: contract.address,
        };
        const expectedDomain = ethers.utils._TypedDataEncoder.hashDomain(domain);
        const actualDomain = await contract.DOMAIN_SEPARATOR();
        expect(actualDomain).eq(expectedDomain);
    });

    it("should accept permit with signature", async () => {
        const types: Record<string, TypedDataField[]> = {
            "Permit": [
                {
                    "name": "owner",
                    "type": "address"
                },
                {
                    "name": "spender",
                    "type": "address"
                },
                {
                    "name": "value",
                    "type": "uint256"
                },
                {
                    "name": "nonce",
                    "type": "uint256"
                },
                {
                    "name": "deadline",
                    "type": "uint256"
                }
            ],
        };
        const deadline = 3600 + Math.round(new Date().getTime() / 1000);
        const nonce = await contract.getNonce(owner.address);
        const message = {
            owner: owner.address,
            spender: spender.address,
            value,
            nonce,
            deadline,
        };
        const signature = await owner._signTypedData(domain, types, message);
        const { v, r, s } = ethers.utils.splitSignature(signature);

        await contract.connect(admin).permit(owner.address, spender.address, value, deadline, v, r, s);
    });

    it("should give some tokens to owner", async () => {
        await contract.connect(admin).transfer(owner.address, value);
    });

    it("should allow transfer tokens from owner to spender", async () => {
        const tx =  contract.connect(spender).transferFrom(owner.address, spender.address, value);
        await expect(tx).to.changeTokenBalances(contract, [owner.address, spender.address], [-value.toBigInt(), value])
    });
});
