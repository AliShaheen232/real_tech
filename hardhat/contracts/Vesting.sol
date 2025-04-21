// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vesting is Ownable, ReentrancyGuard {
    struct VestingDetail {
        bool airdropStatus;
        uint16 percentage;
        uint32 unlockTime; // epoch time
    }

    address public beneficiary;
    uint256 public vestingFunds; // @dev  - Cannot decrement this var
    uint256 public fundsTransferred; // @dev  - Therefore incrementing this var
    uint16 public demoniator = 10000;
    IERC20 public realToken;
    VestingDetail[] public vestingSlots;

    event AirdropREAL(
        address indexed _beneficiary,
        uint256 _amount,
        uint256 airdropTime
    );
    event REALWithdrawn(address indexed _withdrawer, uint256 _amount);
    event DepositFunds(uint256 _amount, uint256 _depositTime);
    event UpdatedVestingSlots(uint16[] _percentage, uint32[] _unlockTime);

    constructor(address _realToken, address _beneficiary) Ownable(msg.sender) {
        require(
            _realToken != address(0),
            "Real token address cannot be zero address"
        );
        require(
            _beneficiary != address(0),
            "Beneficiary address cannot be zero address"
        );
        realToken = IERC20(_realToken);
        beneficiary = _beneficiary;
    }

    function updateVestingSlots(
        uint16[] memory _percentage,
        uint32[] memory _unlockTime
    ) public onlyOwner {
        require(!vestingStatus(), "vesting transfer started");
        require(
            _percentage.length == _unlockTime.length,
            "Array lengths are un-equal"
        );

        uint256 totalPercentage;
        for (uint i; i < _percentage.length; i++) {
            totalPercentage += _percentage[i];
        }

        require(
            totalPercentage == demoniator,
            "Sum of all percentages should be 100%"
        );

        while (vestingSlots.length > 0) {
            vestingSlots.pop();
        }

        for (uint i; i < _percentage.length; i++) {
            vestingSlots.push(
                VestingDetail({
                    airdropStatus: false,
                    percentage: _percentage[i],
                    unlockTime: _unlockTime[i]
                })
            );
        }

        emit UpdatedVestingSlots(_percentage, _unlockTime);
    }

    function depositFunds(uint256 _amount) public nonReentrant {
        require(_amount > 0, "Amount cannot be zero");
        require(!vestingStatus(), "vesting transfer started");
        vestingFunds += _amount;
        SafeERC20.safeTransferFrom(
            realToken,
            msg.sender,
            address(this),
            _amount
        );
        emit DepositFunds(_amount, block.timestamp);
    }

    function airdrop() public onlyOwner nonReentrant {
        uint256 length = vestingSlots.length;
        require(vestingStatus(), "vesting transfer not started");
        require(length > 0, "no Unlock detail");
        require(vestingFunds > fundsTransferred, "Vesting Completed");

        uint256 funds;
        for (uint i; i < length; i++) {
            if (
                vestingSlots[i].unlockTime <= block.timestamp &&
                !vestingSlots[i].airdropStatus
            ) {
                funds +=
                    (vestingFunds * (uint256(vestingSlots[i].percentage))) /
                    demoniator;
                vestingSlots[i].airdropStatus = true;
            }
        }

        require(realToken.balanceOf(address(this)) >= funds, "Low Balance");
        fundsTransferred += funds; // maintaing this var for restriction of any extra transfer, though there are other checks but i'm adding this extra check.

        SafeERC20.safeTransfer(realToken, beneficiary, funds);

        emit AirdropREAL(beneficiary, funds, block.timestamp);
    }

    function withdrawREAL(uint256 _amount) external onlyOwner {
        require(
            realToken.balanceOf(address(this)) >= _amount,
            "Low Real balance"
        );
        SafeERC20.safeTransfer(realToken, msg.sender, _amount);

        emit REALWithdrawn(msg.sender, _amount);
    }

    function vestingStatus() public view returns (bool _status) {
        for (uint i; i < vestingSlots.length; i++) {
            if (vestingSlots[i].unlockTime <= block.timestamp) {
                //@dev - checks if any single date has passed then it's returns "true". Means Vesting has started.
                return true;
            }
        }
    }

    function getVestingSlots() public view returns (VestingDetail[] memory) {
        return vestingSlots;
    }
}
