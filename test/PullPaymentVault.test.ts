import { ethers } from "hardhat";
import { PullPaymentVault__factory, PullPaymentVault, MintableERC20, MintableERC20__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

describe("PullPaymentVault", () => {

    let contract: PullPaymentVault;
    let factory: PullPaymentVault__factory;
    let token: MintableERC20;
    let __tokenFactory: MintableERC20__factory;

    let user: SignerWithAddress;

    const price = 1800;
    before(async () => {
        __tokenFactory = await ethers.getContractFactory("MintableERC20");
        token = await __tokenFactory.deploy("Test USD", "USDTST", ethers.utils.parseEther("1"));
        factory = await ethers.getContractFactory("PullPaymentVault");
        contract = await factory.deploy(token.address, price, {
            value: ethers.utils.parseEther("1")
        });
        user = (await ethers.getSigners())[1];
    });

    const tokenAmount = ethers.utils.parseEther("1800");
    it("should mint some tokens to user", async () => {
        await token.mint(user.address, tokenAmount);
    });

    it("should allow contract to take ERC20 for ETH", async () => {
        await token.connect(user).approve(contract.address, tokenAmount);
    });

    it("should sell ether to user", async () => {
        const tx = contract.connect(user).buyETH(tokenAmount);
        await expect(tx).to.changeEtherBalance(contract.address, -ethers.utils.parseEther("1").toBigInt());
    });

    it("should allow withdraw accrued ether via escrow", async () => {
        const tx = contract.withdrawPayments(user.address);
        await expect(tx).to.changeEtherBalance(user.address, ethers.utils.parseEther("1"));
    });
});
