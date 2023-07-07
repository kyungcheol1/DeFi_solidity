import { ethers } from "hardhat";
import { Contract } from "@ethersproject/contracts";

describe("airdrop", () => {
    let airdrop: Contract;
    let LPToken: Contract;
    let GOVToken: Contract;
    before(async () => {
        const [deployer] = await ethers.getSigners();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const SelfToken = await ethers.getContractFactory("SelfToken");
        GOVToken = await SelfToken.deploy("GovToken", "GTK");
        LPToken = await SelfToken.deploy("LPToken", "LPK");
        airdrop = await Airdrop.deploy("0xa8EaeF888a4e3aBf6efBBC92029BbC09221434b8", "0x7b998015DD35b1f38143c0173e9e6CA1A582ccE5");
        const airAddress = await airdrop.deployaddress();
        await GOVToken.mint(1400);
        await LPToken.mint(2000);
    });

    it.skip("getaddress", async () => {
        const Govaddress = await GOVToken.deployaddress();
        const LPaddress = await LPToken.deployaddress();
        const airaddress = await airdrop.deployaddress();
        const address = {
            Govaddress: "0xa51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0",
            LPaddress: "0x0dcd1bf9a1b36ce34237eeafef220932846bcd82",
            airaddress: "0x9A676e781A523b5d0C0e43731313A708CB607508",
        };
    });

    it("doAirdrop", async () => {
        const GovAmount = await GOVToken.balanceOf("0xa51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0");
        await GOVToken.transfer("0x0dcd1bf9a1b36ce34237eeafef220932846bcd82", 400);
        await GOVToken.transfer("0x9A676e781A523b5d0C0e43731313A708CB607508", 400);
        await LPToken.approve("0x9A676e781A523b5d0C0e43731313A708CB607508", 1000);

        const airLPAmount = await LPToken.balanceOf("0x9A676e781A523b5d0C0e43731313A708CB607508");
        console.log("0x9A676e781A523b5d0C0e43731313A708CB607508" == (await airdrop.deployaddress()));
        console.log(GovAmount, airLPAmount);

        const address = {
            Govaddress: "0xa51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0",
            LPaddress: "0x0dcd1bf9a1b36ce34237eeafef220932846bcd82",
            airaddress: "0x9A676e781A523b5d0C0e43731313A708CB607508",
        };
        const data = await airdrop.doAirdrop([address.Govaddress, address.LPaddress, address.airaddress], address.LPaddress, address.Govaddress);
        const LPGovAmount = await LPToken.balanceOf("0xa51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0");
        const LPairAmount = await LPToken.balanceOf("0x0dcd1bf9a1b36ce34237eeafef220932846bcd82");
        const LPlpAmount = await LPToken.balanceOf("0x9A676e781A523b5d0C0e43731313A708CB607508");

        console.log(GovAmount, airLPAmount, LPGovAmount, LPairAmount, LPlpAmount);
    });

    it.skip("divuu", async () => {
        const a = await airdrop.div(300, 1000);
        console.log(a);
    });
});

