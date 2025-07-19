const {ethers} = require("hardhat");
const {expect} = require("chai");

describe("Auction Contract", function () {
    it("should create an auction", async function () {
        const [signer, buyer] = await ethers.getSigners()
        await deployments.fixture(["deployNftAuction"]);
        
        const nftAuctionProxy = await deployments.get("NftAuctionProxy");
        const nftAuction = await ethers.getContractAt(
            "NftAuction",
            nftAuctionProxy.address
        );


        // 1. 部署 ERC721 合约
        const TestERC721 = await ethers.getContractFactory("TestERC721");
        const testERC721 = await TestERC721.deploy();
        await testERC721.waitForDeployment();
        const testERC721Address = await testERC721.getAddress();
        console.log("testERC721Address::", testERC721Address);
         // mint 10个 NFT
            for (let i = 0; i < 10; i++) {
                await testERC721.mint(signer.address, i + 1);
            }
         const tokenId = 1;    

        // 给代理合约授权
        await testERC721.connect(signer).setApprovalForAll(nftAuctionProxy.address, true);

        // 创建拍卖
        await nftAuction.createAuction(
            11,
            ethers.parseEther("0.01"),
            testERC721Address, // 使用ERC721作为支付方式
            tokenId
         );
        const auction = await nftAuction.auctions(0);
        console.log("拍卖创建成功:", auction);


        //await nftAuction.connect(buyer).placeBid(0, {value: ethers.parseEther("0.011")});
        tx=await nftAuction.connect(buyer).placeBid(0, 0, ethers.ZeroAddress, { value: ethers.parseEther("0.011") });
        await tx.wait();
        console.log("交易哈希:", tx.hash);
        console.log("参与拍卖成功");
        const auctionAfterBid = await nftAuction.auctions(0);
        console.log("参与拍卖成功:", auctionAfterBid);

        //等待10S
        await new Promise(resolve => setTimeout(resolve, 10));
        //结束拍卖 
        await nftAuction.connect(signer).endAuction(0);

        //验证拍卖结束
       
        const auctionResult = await nftAuction.auctions(0);
        console.log("结束拍卖后读取拍卖成功：：", auctionResult);
        expect(auctionResult.highestBidder).to.equal(buyer.address);
        expect(auctionResult.highestBid).to.equal(ethers.parseEther("0.011"));

        // 验证 NFT 所有权
        const owner = await testERC721.ownerOf(tokenId);
        console.log("owner::", owner);
        expect(owner).to.equal(buyer.address);
        });
});