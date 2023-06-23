import {ethers} from "hardhat"
import { Contract } from "@ethersproject/contracts";

describe("Pool_V1", function (){
    let pool: Contract
    let deployer: any
    before(async function(){
        const [_deployer] = await ethers.getSigners()
        deployer = _deployer
        const Pool = await ethers.getContractFactory("Pool_v1", deployer)
        pool = await Pool.deploy(1)
        
    })

    it.skip("state variable test", async function(){
        console.log(await pool.LpAddress(), "이건 Lp address여!")
        const Lpaddress = await pool.LpAddress()
        console.log(Lpaddress, "Lp 할당!!")
    })

    it.skip("calc check", async function(){
        const _token1 = "0xaE036c65C649172b43ef7156b009c6221B596B8b"
        const _token2 =  "0x9d83e140330758a8fFD07F8Bd73e86ebcA8a5692"
        const amount1 = 20
        const amount2 = 100
        const totalTokenamount = await pool.callStatic.calclending(_token1, amount1, _token2, amount2);
        console.log(totalTokenamount)
    }) 

    it("ArbAsdPool", async function(){
        const _arbToken = "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8"
        const _asdToken = "0xf8e81D47203A594245E36C48e151709F0C19fBe8"
        const arbAmount = 20
        const asdAmount = 30 
        const arbPool = await pool.callStatic.ArbAsdPool(_arbToken,_asdToken,arbAmount,asdAmount)
        console.log(arbPool)
    })
})