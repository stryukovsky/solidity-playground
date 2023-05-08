import { ethers } from "hardhat";
import { _TypedDataEncoder, keccak256, splitSignature } from "ethers/lib/utils";
import { SignatureERC20, SignatureERC20__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber, TypedDataDomain, TypedDataField } from "ethers";
import { expect } from "chai";

const ACTION_ALLOW = keccak256(ethers.utils.toUtf8Bytes("ACTION_ALLOW"));
const ACTION_TRANSACT = keccak256(ethers.utils.toUtf8Bytes("ACTION_TRANSACT"));

interface StructSignatureERC20Action {
    from: string;
    to: string;
    value: BigNumber;
    action: string
    nonce: number | BigNumber,
    deadline: number | BigNumber,
}

describe("SignatureERC20", () => {

    let factory: SignatureERC20__factory;
    let contract: SignatureERC20;

    const name = "Tether USD";
    const symbol = "USDT";
    const version = "v1.0";
    const chainId = 31337;

    let domain: TypedDataDomain;
    let types: Record<string, TypedDataField[]>;

    let executor: SignerWithAddress;
    let vault: SignerWithAddress;
    let owner: SignerWithAddress;
    let spender: SignerWithAddress;
    let stranger: SignerWithAddress;

    const initialSupply = ethers.utils.parseEther("1000000");
    before(async () => {
        const signers = await ethers.getSigners();

        executor = signers[0];
        vault = signers[1];
        owner = signers[2];
        spender = signers[3];
        stranger = signers[4];

        factory = await ethers.getContractFactory("SignatureERC20");
        contract = await factory.deploy(vault.address, initialSupply, name, version, symbol);

        domain = {
            name,
            version,
            chainId,
            verifyingContract: contract.address
        }

        types = {
            SignatureERC20Action: [
                { type: "address", name: "from" },
                { type: "address", name: "to" },
                { type: "uint256", name: "value" },
                { type: "bytes32", name: "action" },
                { type: "uint256", name: "nonce" },
                { type: "uint256", name: "deadline" },
            ]
        }

    });

    const signTransaction = async (signer: SignerWithAddress, message: StructSignatureERC20Action) => {
        return splitSignature(await signer._signTypedData(domain, types, message));
    };

    it("should have proper domain hash", async () => {
        const hashedDomain = _TypedDataEncoder.hashDomain(domain);
        const actualDomain = await contract.domainSeparatorV4();
        expect(actualDomain).eq(hashedDomain);
    });

    const value = ethers.utils.parseEther("1");
    it("should perform initial transfer from vault to owner", async () => {
        const nonce = await contract.getNonce(vault.address);
        const deadline = 3600 + Math.round(new Date().getTime() / 1000);
        const { v, r, s } = await signTransaction(vault, {
            from: vault.address,
            to: owner.address,
            value,
            action: ACTION_TRANSACT,
            nonce,
            deadline,
        });
        const tx = contract.connect(executor).transact(vault.address, owner.address, value, deadline, v, r, s);
        await expect(tx).to.changeTokenBalances(contract, [vault.address, owner.address], [-value.toBigInt(), value]);
    });

    it("should give allowance from owner to spender", async () => {
        const nonce = await contract.getNonce(owner.address);
        const deadline = 3600 + Math.round(new Date().getTime() / 1000);
        const { v, r, s } = await signTransaction(owner, {
            from: owner.address,
            to: spender.address,
            value,
            action: ACTION_ALLOW,
            nonce,
            deadline,
        });
        await contract.allow(owner.address, spender.address, value, deadline, v, r, s);
    });
});
