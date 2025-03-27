Requirements:
The owner will

- deploy the contract.
- will mention 4 dates of unlocking the amount as a percentage %
- Will mention the % amount for each date
- Will mention receiver address (beneficiary)

Deposit of tokens can come from anyone. The contract will hold the tokens until the unlock dates.

The receiver will

- At each unlock date the receiver has to withdraw tokens from the smart contract.
- They must know how to withdraw using etherscan or other ethereum explorers.
- They must pay the ethereum network fee.
- Can the contract airdrop the unlocked amount??

The "owner" from deployment will trigger the airdrop after each unlock date. and then the "reciever" will recieve the airdrop.
So I will trigger the airdrop after each unlock date.. then the person receiving the tokens will recieve the airdrop..


Solution:
Methods Name: `updateVestingSlots`, `depositFunds`, `airdrop`, `getVestingSlots`

At time of deployment, pass Real token address and beneficiary address both address should not be zero address. 

After deployment, Call this `updateVestingSlots` method. In this method pass percentages in array format. 

```sample params data
percentage array: [2500,2500,2500,2500]
epoch timestamp array: [1743100410,1743100310,1743100510,1743100610]
```
percentage total should be equal to 10000, but 4 values are not compulsory minimum value is 1 and maximum value is upto 10000. 

Note: This method updates vesting slots each time when owner call this method. old slots get replaced with new slots and old data got deleted.

For depositing funds in contract, call this `depositFunds` method. Before calling this method, give allownace of Real tokens to contract. Anyone can call this method for depositing the funds. But when any slot got meatured, it'll return an error of depositing the funds in contract. 

Anyone can transfer Real tokens (funds) in this contract without using this `depositFunds`. but contract would not consider this transferred amount for vesting.

When any slot has meatured then owner can call `airdrop` method. this will transfer vested amount in beneficiary account. If all slots get meature then it returns error of "Vesting Completed".

You can check all vesting slots by calling this method `getVestingSlots`. 

