const { deployments, upgrades, ethers } = require("hardhat");

const fs = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log("部署用户地址:", deployer);

    //合约工厂拿到合约
    const NftAuction = await ethers.getContractFactory("NftAuction");
    //通过代理部署合约
    const ntfAuctionProxy = await upgrades.deployProxy(NftAuction, [], {
        initializer: "initialize",
    });

    //等待部署成功
    await ntfAuctionProxy.waitForDeployment();

    const proxyAddress = await ntfAuctionProxy.getAddress();
    //实现合约地址
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);


    console.log(`代理合约地址 : ${proxyAddress}`);
    console.log(`实现合约地址 : ${implementationAddress}`);


    //-------部署信息保存本地
    const storaPath = path.join(__dirname, "./.cache/proxyNftAuction.json");

    fs.writeFileSync(
        storaPath,
        JSON.stringify({
        proxyAddress,
        implementationAddress,
        abi: NftAuction.interface.format("json"),
        })
    );
     await save("NftAuctionProxy", {
    abi: NftAuction.interface.format("json"),
    address: proxyAddress,
  })

};


module.exports.tags = ["deployNftAuction"];