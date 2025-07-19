require("@nomicfoundation/hardhat-toolbox");
require('hardhat-deploy')
require("@openzeppelin/hardhat-upgrades");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    deployer: 0,
    user1: 1,
    user2: 2,
    user3: 3,
  },
  networks: {
    hardhat: {
      // 本地测试网络
    },
    // sepolia: {
    //   url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts: [
    //     process.env.PRIVATE_KEY, // 部署账户的私钥
    //   ],
    //   chainId: 11155111,
    //   timeout: 300000, // 5 分钟网络超时
    //   gas: "auto",
    //   gasPrice: "auto",
    // },
  },
};
