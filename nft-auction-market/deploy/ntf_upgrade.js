const { deployments, upgrades, ethers } = require("hardhat");

const fs = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log("部署用户地址:", deployer);
    // 读取 .cache/proxyNftAuction.json文件
  const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");
  const storeData = fs.readFileSync(storePath, "utf-8");
  const { proxyAddress, implAddress, abi } = JSON.parse(storeData);
    //合约工厂拿到合约
    const NftAuctionV2 = await ethers.getContractFactory("NftAuctionV2");
    //通过代理升级合约
    const ntfAuctionProxyV2 = await upgrades.upgradeProxy(proxyAddress, NftAuctionV2);

    //等待部署成功
    await ntfAuctionProxyV2.waitForDeployment();

    const proxyAddressV2 = await ntfAuctionProxyV2.getAddress();

    const implementationAddressV2 = await upgrades.erc1967.getImplementationAddress(proxyAddressV2);

    console.log(`代理合约地址 : ${proxyAddress}`);
    console.log(`实现合约地址 : ${implementationAddressV2}`);


    await save("NftAuctionProxyV2", {
        abi: NftAuctionV2.interface.format("json"),
        address: proxyAddress,
    });


};


module.exports.tags = ["upgradeNftAuction"];