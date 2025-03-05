/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
// require("@openzeppelin/hardhat-upgrades");

module.exports = {
  networks: {
    eth: {
      url: "https://mainnet.infura.io/v3/335d7bd80d5747f482a8c603c4beae14",
      accounts: [
        "ed785a8003c4f339519655f3c99e1237004eb6f06a0ca7d8d450ea6045a083fd",
      ],
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [
        "8f9faefa27950a4724eebcbb841ff8fc7915d2bcf6ca9413aa81b8c4b3e93762",
      ],
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/335d7bd80d5747f482a8c603c4beae14",
      accounts: [
        "1f806af233b232a325874e13a7ccf63cb65e219165e956a684829cbfe3aac25e", // 0x52C75ad49024dB2474cB8a581F625bee2E14e8E7
      ],
    },
    strm: {
      url: "http://34.229.101.191:40002",
      accounts: [
        "8f9faefa27950a4724eebcbb841ff8fc7915d2bcf6ca9413aa81b8c4b3e93762",
      ],
    },
    tbsc: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [
        "8f9faefa27950a4724eebcbb841ff8fc7915d2bcf6ca9413aa81b8c4b3e93762",
      ],
    },
  },
  etherscan: {
    apiKey: "4KTNSWY9R5HZRY9YP1WTQXPS277262DNWW",
  },
  sourcify: {
    enabled: true,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.20",
      },
      {
        version: "0.8.28",
      },
    ],
  },
};
