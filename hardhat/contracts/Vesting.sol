// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract FreeREALDistributor is Ownable, ReentrancyGuard, Pausable {
    struct UnlockDetail {
        bool airdropStatus;
        uint16 percentage;
        uint32 unlockTime;
    }

    uint256 public vestingFund;
    IERC20 public realToken;
    UnlockDetail[] public ulockDetails;

    constructor(address _realToken) Ownable(msg.sender) {
        realToken = IERC20(_realToken);
    }

    function updateUnlockDetail(
        uint16 _percentage,
        uint32 _unlockTime
    ) public onlyOwner {

        delete
    }

    function addFunds(uint256 _amount) public nonReentrant {
        vestingFund += _amount;
        realToken.transferFrom(msg.sender, address(this), _amount);
    }

    // function airdrop() public onlyOwner nonReentrant {

    //     require(realToken.balanceOf(address(this)), "Low Balance");
    // }
}
