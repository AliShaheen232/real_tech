const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log(
    `🚀 ~ main ~ await network.provider.request({ method: "hardhat_reset", params: [] }):`,
    await network.provider.request({ method: "hardhat_reset", params: [] })
  );
}

main();
