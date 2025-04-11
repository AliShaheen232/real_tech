const Web3 = require("web3");
const fs = require("fs");

const web3 = new Web3.default(
  "https://mainnet.infura.io/v3/335d7bd80d5747f482a8c603c4beae14"
);

const PVT_KEY =
  "0x1f806af233b232a325874e13a7ccf63cb65e219165e956a684829cbfe3aac25e"; // @dev - dummy private key for address 0x52C75ad49024dB2474cB8a581F625bee2E14e8E7
const account = web3.eth.accounts.privateKeyToAccount(PVT_KEY);

const userAddress = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"; // @dev -  require user address from F.E.
const JWToken = "replace_with_original_jwtoken"; // @dev - replace with Original JWToken, also do a verification of this token to aviod any kind of bypass

const claimMessage = async (userAddress) => {
  const balance = await web3.eth.getBalance(userAddress);

  const epochTime = Date.now();

  const text = web3.utils.soliditySha3(
    { type: "string", value: "CLAIM" },
    { type: "address", value: userAddress },
    { type: "uint256", value: balance },
    { type: "uint256", value: epochTime },
    { type: "string", value: JWToken }
  );

  fs.appendFileSync(
    "./claim_log.txt",
    `\nCLAIM:${userAddress}:${balance}:${epochTime}:${JWToken}`
  );

  console.log(text);
  return text;
};

const signMessage = (message) => {
  const signed = account.sign(message);
  return signed.signature;
};

claimMessage(userAddress).then((message) => {
  signature = signMessage(message);
  console.log({ message, signature });

  return { message, signature };
});
