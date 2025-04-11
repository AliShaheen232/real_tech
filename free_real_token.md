@backend-dev: Create an API to use this nodeJS script, client(frontend) will call this API by passing user address and JWToken. Backend should validate this JWToken. replace dummy `PVT_KEY` with client signer private key.

@frontend-dev: After calling this API client side will receive the response as object consist of { message, signature }, So while calling `claimREAL` method on blockchain pass `message and signature` as params.

@blockchain-dev: At time of deployment pass REAL token address, client signer address, claimable amount in WEI and hardcap amount in WEI. client signer address is changable by using this method `setClientSigner`.

Note: When Frontend pass the call to smart contract triggered by the user with params of `message and signature` then smart contract validate this signature with the client signer address if signture matches with the address then user can get successfully receive the token otherwise it reverts the error "invalid signer".
