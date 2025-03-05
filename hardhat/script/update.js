const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  const ICO = await ethers.getContractFactory("ICO");
  const ico = await ICO.attach("0x7B73bf56F3173948Bc222776Eff6f823A40CE485");

  const rawData = fs.readFileSync("wallets.json");
  const users = JSON.parse(rawData);

  const userDataArray = users.map((user) => ({
    userAddress: user.userAddress,
    amount: user.amount,
  }));

  const chunkSize = 1000;
  for (let i = 0; i < userDataArray.length; i += chunkSize) {
    const chunk = userDataArray.slice(i, i + chunkSize);

    try {
      const tx = await ico.addUserData(chunk);
      await tx.wait();
      console.log(
        `Added chunk ${i / chunkSize + 1}/${Math.ceil(
          userDataArray.length / chunkSize
        )}`
      );
    } catch (error) {
      console.error("Error adding chunk:", error);
      return; // Stop if there's an error
    }
  }

  console.log("All user data added successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

//   --network sepolia
// main ~ deployer address: 0x52C75ad49024dB2474cB8a581F625bee2E14e8E7
// 🚀 ~ main ~ realTestToken: 0x15E9cD7914a33D5c3A31151AB55d05605d672a6B
// 🚀 ~ main ~ icoContract: 0x7B73bf56F3173948Bc222776Eff6f823A40CE485
// 5-March-2025
