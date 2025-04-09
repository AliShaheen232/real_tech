const web3 = require("web3");

const PVT_KEY =
  "0x1f806af233b232a325874e13a7ccf63cb65e219165e956a684829cbfe3aac25e";
const account = web3.eth.accounts.privateKeyToAccount(PVT_KEY);

const claimMessage = () => {
  const userAddress = "0xFc917f58Cf1E2885636AbADA3307b6a3013a4959";
  const epochTime = Date.now();
  console.log(
    "🚀 ~ main ~ `CLAIM:${userAddress}:${epochTime}`:",
    `CLAIM:${userAddress}:${epochTime}`
  );
  return `CLAIM:${userAddress}:${epochTime}`;
};

const signMessage = (message) => {
  const signed = account.sign(message);
  return signed.signature;
};

const message = claimMessage();
const signature = signMessage(message);
console.log("🚀 ~ signature:", signature);

// 0x52C75ad49024dB2474cB8a581F625bee2E14e8E7

// 0x52C75ad49024dB2474cB8a581F625bee2E14e8E7