Vesting Factory is Ownable, Pausable contract secured with ReentrancyGuard. 
1. Deployer need to pass owner and REAL token addresses while deploying VestingFactory.

    a. Real Token holders could use `deployVesting` method to lock their funds. While calling this method users need to pass {Amount for vesting, Total events, Vesting duration and vesting memo note} condition contract should be `unpaused`. 

    Note: Before calling `deployVesting` method users must approve vesting amount to Vesting Factory contract. 

2. After calling `deployVesting` method, New contract of Vesting get deployed and user shall be owner of this Vesting contract. 
    a. User can unlock their amount at each `eventMaturityTime`.
    b. While unlocking the amount user need to pass `_unlockingMemo` unlocking memo note.


3. Vesting Factory have `getPaginatedDeployedAddresses` method by this anyone can see all deployed contract addresses deployed by this factory by just page number and size of page required as parametes in this method. 

4. Owner of Vesting Factory can pause and upause "Vesting Factory Contract" by calling `pause` and `unpause` methods respectively.  
