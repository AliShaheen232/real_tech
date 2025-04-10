const Web3 = require("web3");

const web3 = new Web3.default(
  "https://mainnet.infura.io/v3/335d7bd80d5747f482a8c603c4beae14"
);

const PVT_KEY =
  "0x1f806af233b232a325874e13a7ccf63cb65e219165e956a684829cbfe3aac25e";
const account = web3.eth.accounts.privateKeyToAccount(PVT_KEY);

const userAddress = "0xFc917f58Cf1E2885636AbADA3307b6a3013a4959"; //@dev -  dummy user address replace this while calling from API

const claimMessage = async (userAddress) => {
  const balance = await web3.eth.getBalance(userAddress);
  const epochTime = Date.now();

  const text = web3.utils.soliditySha3(
    { type: "string", value: "CLAIM" },
    { type: "address", value: userAddress },
    { type: "uint256", value: balance },
    { type: "uint256", value: epochTime }
  );

  console.log("CLAIM:${userAddress}:${epochTime}:", text);
  return text;
};

const signMessage = (message) => {
  const signed = account.sign(message);
  return signed.signature;
};

claimMessage(userAddress).then((message) => {
  signature = signMessage(message);
  console.log(` { message, signature }:`, { message, signature });
  return { message, signature };
});
// 0x52C75ad49024dB2474cB8a581F625bee2E14e8E7
