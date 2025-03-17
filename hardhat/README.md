At time of deployment:
1. Pass "REAL" token address
2. Pass "HARDCAP" amount in WEI
3. Pass "distPercentage" distributionn percentange value in multiple of "100". e.g. for 10% pass 10000 and for 21.05% pass 2105
4. Deposit REAL tokens in this deployed contract.

Claiming Process: 
1. Users can claim free tokens only once in their lifetime.
2. The contract checks the user's REAL token balance. It calculates the claimable amount based on the `distPercentage`, and it could be 49% maximum.

e.g. `distPercentage` is 10% (10000) and user's balance is "10 REAL tokens" then user able to claim "1 REAL token".
