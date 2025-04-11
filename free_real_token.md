@backend-dev: Create an API to use this nodeJS script, client(frontend) will call this API by passing user address and JWToken. Backend should validate this JWToken. replace dummy `PVT_KEY` with actual client signer private key. The response should include object with  `{ message, signature }`.

@frontend-dev: After calling this API client side will receive the response as object consist of { message, signature }, So while calling `claimREAL` method on blockchain pass `message and signature` as params.

@blockchain-dev: At time of deployment pass REAL token address, client signer address, claimable amount (in WEI) and hardcap amount (in WEI).  The client signer address can be updated later using the `setClientSigner` method.

Note: When Frontend pass the call to smart contract triggered by the user with params of `message and signature` then smart contract validate this signature with the client signer address if signture matches with the address then user can get successfully receive the token otherwise the transaction is reverted with the error "invalid signer".
