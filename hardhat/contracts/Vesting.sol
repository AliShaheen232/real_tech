// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FreeREALDistributor is Ownable, ReentrancyGuard {
    struct UnlockDetail {
        bool airdropStatus;
        uint16 percentage;
        uint32 unlockTime; // epoch time
    }

    address public beneficiary;
    uint256 public vestingFunds; // @dev  - Cannot decrement this var
    uint256 public fundsTransferred; // @dev  - Therefore incrementing this var
    uint16 public demoniator = 10000;
    IERC20 public realToken;
    UnlockDetail[] public unlockDetails;

    event AirdropREAL(
        address indexed _beneficiary,
        uint256 _amount,
        uint256 airdropTime
    );
    event REALWithdrawn(address indexed _withdrawer, uint256 _amount);

    constructor(address _realToken, address _beneficiary) Ownable(msg.sender) {
        realToken = IERC20(_realToken);
        beneficiary = _beneficiary;
    }

    function updateUnlockDetails(
        uint16[] memory _percentage,
        uint32[] memory _unlockTime
    ) public onlyOwner {
        require(!vestingStatus(), "vesting transfer started");
        
        while (unlockDetails.length > 0) {
            unlockDetails.pop();
        }
        require(
            _percentage.length == _unlockTime.length,
            "Array lengths are un-equal"
        );
        unlockDetails = new UnlockDetail[](_percentage.length);
        for (uint i; i < _percentage.length; i++) {
            unlockDetails[i].percentage = _percentage[i];
            unlockDetails[i].unlockTime = _unlockTime[i];
        }
    }

    function addFunds(uint256 _amount) public nonReentrant {
        require(!vestingStatus(), "vesting transfer started");
        vestingFunds += _amount;
        realToken.transferFrom(msg.sender, address(this), _amount);
    }

    function airdrop() public onlyOwner nonReentrant {
        uint256 length = unlockDetails.length;

        require(length > 0, "no Unlock detail");
        require(vestingFunds > fundsTransferred, "Vesting Completed");

        uint256 funds;
        for (uint i; i < length; i++) {
            if (
                unlockDetails[i].unlockTime <= block.timestamp &&
                !unlockDetails[i].airdropStatus
            ) {
                funds +=
                    (vestingFunds * (uint256(unlockDetails[i].percentage))) /
                    demoniator;
                unlockDetails[i].airdropStatus = true;
            }
        }

        require(realToken.balanceOf(address(this)) >= funds, "Low Balance");
        fundsTransferred += funds; // maintaing this var for restriction of any extra transfer, though there are other checks but i'm adding this extra check.

        realToken.transfer(beneficiary, funds);

        emit AirdropREAL(beneficiary, funds, block.timestamp);
    }

    function withdrawREAL(uint256 _amount) external onlyOwner {
        require(
            realToken.balanceOf(address(this)) >= _amount,
            "Presale: Not enough REAL in contract"
        );
        realToken.transfer(msg.sender, _amount);

        emit REALWithdrawn(msg.sender, _amount);
    }

    function vestingStatus() public view returns (bool _status) {
        for (uint i; i < unlockDetails.length; i++) {
            if (unlockDetails[i].unlockTime <= block.timestamp) {
                return true;
            }
        }
    }
}
