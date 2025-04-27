Vesting Factory is Ownable, Pausable contract secured with ReentrancyGuard. 
1. Deployer need to pass owner and REAL token addresses while deploying VestingFactory.

    a. Real Token holders could use `deployVesting` method to lock their funds. While calling this method users need to pass {Amount for vesting, Total events, Vesting duration and vesting memo note} condition contract should be `unpaused`. 

    Note: Before calling `deployVesting` method users must approve vesting amount to Vesting Factory contract. 
