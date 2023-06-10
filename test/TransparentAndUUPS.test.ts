import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ExampleTransparent, ExampleUUPS, ExampleTransparent__factory, ExampleUUPS__factory} from "../typechain-types";
import {upgrades, ethers} from "hardhat";
import { BigNumber } from "ethers";
import { expect } from "chai";

describe("Transparent VS UUPS upgrade", () => {
    let transparent: ExampleTransparent;
    let transparentFactory: ExampleTransparent__factory;
    let uups: ExampleUUPS;
    let uupsFactory: ExampleUUPS__factory;

    let deployer: SignerWithAddress;


    before(async () => {
        transparentFactory = await ethers.getContractFactory("ExampleTransparent");
        transparent = await upgrades.deployProxy(transparentFactory, []) as ExampleTransparent;
        
        uupsFactory = await ethers.getContractFactory("ExampleUUPS");
        uups = await upgrades.deployProxy(uupsFactory, []) as ExampleUUPS;

        [deployer] = await ethers.getSigners();
    });

    let transparentUpgradePrice: BigNumber;
    it("should upgrade Transparent", async () => {
        const nativeBalanceBefore = await deployer.getBalance();
        await upgrades.upgradeProxy(transparent, transparentFactory);
        const nativeBalanceAfter = await deployer.getBalance();
        transparentUpgradePrice = nativeBalanceBefore.sub(nativeBalanceAfter);
    });

    let uupsUpgradePrice: BigNumber;
    it("should upgrade UUPS", async () => {
        const nativeBalanceBefore = await deployer.getBalance();
        await upgrades.upgradeProxy(uups, uupsFactory);
        const nativeBalanceAfter = await deployer.getBalance();
        uupsUpgradePrice = nativeBalanceBefore.sub(nativeBalanceAfter);
    });

    it("UUPS should be cheaper than Transparent", async () => {
        expect(uupsUpgradePrice).lt(transparentUpgradePrice);

        console.log(`Transparent upgrade price ${ethers.utils.formatUnits(transparentUpgradePrice.toString(), "gwei")} GWei`);
        console.log(`UUPS    upgrade     price ${ethers.utils.formatUnits(uupsUpgradePrice.toString(), "gwei")} GWei`);
    });


});
