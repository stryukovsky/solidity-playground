import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { HoneyPot, MintableERC20 } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";


describe("HoneyPot", () => {
    let honeyPot: HoneyPot;
    let purchaseToken: MintableERC20;

    let honeyPotDeployer: SignerWithAddress;
    let victim: SignerWithAddress;
    let dex: SignerWithAddress; // suppose this is DEX where we can sell HoneyPot token

    const purchaseTokenSupply = ethers.utils.parseEther("100");
    const priceBasisPoints = 5000;
    before(async () => {
        const signers = await ethers.getSigners();
        honeyPotDeployer = signers[1];
        victim = signers[2];
        dex = signers[3];

        purchaseToken = await(await ethers.getContractFactory("MintableERC20")).deploy("Tether USD", "USDT", purchaseTokenSupply);
        honeyPot = await (await ethers.getContractFactory("HoneyPot")).connect(honeyPotDeployer).deploy(purchaseToken.address, priceBasisPoints);
    });

    const userBalancePurchaseToken = ethers.utils.parseEther("10");
    it("should give some USDT to victim firstly", async () => {
        await purchaseToken.mint(victim.address, userBalancePurchaseToken);
    });

    const victimWantsHoneyPotAmount = ethers.utils.parseEther("5");
    it("should accept victim's USDT to buy HoneyPot tokens", async () => {
        const neededPurchaseToken = await honeyPot.getNeededPaymentTokenAmount(victimWantsHoneyPotAmount);
        const tx = await purchaseToken.connect(victim).approve(honeyPot.address, neededPurchaseToken);
        await tx.wait();
        await honeyPot.connect(victim).buyToken(victimWantsHoneyPotAmount);
    });

    it("should deny any attempt to sell honey pot token", async () => {
        const attempt = honeyPot.connect(victim).transfer(dex.address, 10000);
        await expect(attempt).to.be.revertedWith("UNAUTHORIZED");
    });
});
