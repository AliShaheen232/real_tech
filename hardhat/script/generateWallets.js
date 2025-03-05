const fs = require("fs");
const web3 = require("web3");

const generateWallets = (count) => {
  let wallets = [];

  for (let i = 0; i < count; i++) {
    const wallet = web3.eth.accounts.create();
    wallets.push({
      userAddress: wallet.address,
      amount: web3.utils.fromWei(
        BigInt(Math.floor(Math.random() * 10000 * 10 ** 18) + 1),
        "wei"
      ),
    });
  }

  return wallets;
};

const walletsData = generateWallets(10000);
fs.writeFileSync("wallets.json", JSON.stringify(walletsData, null, 2));

console.log("Generated 1000 wallet addresses and saved to wallets.json");
