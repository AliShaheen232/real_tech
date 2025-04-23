const { ethers, upgrades } = require("hardhat");

// const stakingTokenAdd = "0xB58EEC46081E5F192A9d8B4817a5e938667bB368"; // sepolia network address
// const rewardTokenAdd = "0xB58EEC46081E5F192A9d8B4817a5e938667bB368"; // sepolia network address

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("main ~ deployer address:", deployer.address);

  const Real = await ethers.getContractFactory("Real");
  const real = await Real.deploy(deployer.address);
  const realAddress = await real.getAddress();
  console.log("🚀 ~ main ~ realTokenAddress:", realAddress);

  const VestingFactory = await ethers.getContractFactory("VestingFactory");
  const vestingFactory = await VestingFactory.deploy(
    deployer.address,
    realAddress
  );
  const vestingAddress = await vestingFactory.getAddress();
  console.log("🚀 ~ main ~ factory:", vestingAddress);

  // ================== UPGRADE ================= 0xF078D98e80073F23139381A6E0Ea119C3Fa06fF6
  // for contract upgrade,  use below code.

  //   const ZentuStaking = await ethers.getContractFactory("ZentuLPStaking");
  //   await upgrades.upgradeProxy("mainnet address here", ZentuStaking);
  //   console.log("Box upgraded");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
