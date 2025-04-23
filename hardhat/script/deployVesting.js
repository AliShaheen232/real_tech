const { ethers, upgrades } = require("hardhat");

const factoryAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const realAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const amountMint = "100000000000000000000000000";
const _vestingAmount = "1000000000000000000000";
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("main ~ deployer address:", deployer.address);

  const Real = await ethers.getContractFactory("Real");
  const real = await Real.attach(realAddress);
  await real.mint(deployer.address, amountMint);
  await real.approve(factoryAddress, _vestingAmount);

  const VestingFactory = await ethers.getContractFactory("VestingFactory");
  const vestingFactory = await VestingFactory.attach(factoryAddress);

  const deploy = await vestingFactory.deployVesting(
    _vestingAmount,
    8,
    110,
    "all Ok"
  );
  console.log("🚀 ~ main ~ deploy:", await deploy.wait());
  console.log("🚀 ~ main ~ hash:", deploy.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

//   uint256 _vestingAmount,
//   uint8 _totalEvents,
//   uint8 _vestingDuration,
//   string memory _vestingMemo
