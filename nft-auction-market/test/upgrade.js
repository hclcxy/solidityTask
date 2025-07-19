const {ethers, upgrades,deployments} = require("hardhat");
const ntf_Auction = require("../deploy/ntf_Auction");
const {expect} = require("chai");


describe("NftAuctionV2 Upgrade Test", function () {

    it("should have the correct initial state", async function () {

        //1.部署合约
        await deployments.fixture(["deployNftAuction"]);

        const nftAuctionProxy = await deployments.get("NftAuctionProxy");
        console.log(nftAuctionProxy)

        //2.创建合约
        const nftAuction = await ethers.getContractAt("NftAuction", nftAuctionProxy.address);
        nftAuction.createAuction(
            100 * 1000, 
            ethers.parseEther("0.01"),
            ethers.ZeroAddress,
            1
            );
        const auctions = await nftAuction.auctions(0);
        console.log("创建拍卖成功", auctions);

        //升级合约前实现地址
        const implAddress    = await upgrades.erc1967.getImplementationAddress(nftAuctionProxy.address);

        console.log("升级前实现地址", implAddress);

        //3.升级合约
         await deployments.fixture(["upgradeNftAuction"]);

         //升级后实现地址
         const implAddressV2 = await upgrades.erc1967.getImplementationAddress(nftAuctionProxy.address);

         console.log("升级后实现地址", implAddressV2);


        //4.验证升级
        const auction2= await nftAuction.auctions(0);
        console.log("升级拍卖成功", auction2);
        expect(auction2.startTime).to.equal(auction2.startTime);

        const NftAuctionV2 = await ethers.getContractAt("NftAuctionV2", nftAuctionProxy.address);
        const helloMessage = await NftAuctionV2.testHello();
        expect(helloMessage).to.equal("Hello, World!");

    
    });



})