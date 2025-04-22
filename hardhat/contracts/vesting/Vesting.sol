// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Vesting is Ownable, ReentrancyGuard {
    using Strings for address;
    using Strings for uint;

    struct EventDetail {
        uint8 eventNumber;
        uint256 lockedAmount;
        uint32 eventMaturityTime;
        bool unlockStatus;
    }

    uint8 public totalEvents; // @dev unlock event range 1-10
    uint8 public matureEvents;
    uint32 public vestingDuration; // @dev unlock duration range 1-120 months
    uint32 public startTime;
    uint32 public lastUnlockTime;
    uint32 public eventSpan;
    uint256 public lockedFund;
    uint256 public unlockedFund;
    string[] public memo;
    EventDetail[] public eventDetails;

    IERC20 public realToken;

    event VestingStarted(
        uint256 amount,
        uint8 totalEvents,
        uint32 vestingDuration,
        uint256 startTime
    );
    event UnlockedEvent(uint256 amount, uint8 eventCount, uint256 unlockedTime);

    function initialize(
        address _realToken,
        uint256 _amount,
        uint8 _totalEvents,
        uint8 _vestingDuration,
        string memory _vestingMemo
    ) public Ownable(msg.sender) {
        // @dev - {_vestingDuration} must be in number of months. e.g. 1 ~ 1 month , 10 ~ 10 months
        require(
            _realToken != address(0),
            "Real token address cannot be zero address"
        );

        require(_totalEvents <= 10 && _totalEvents > 0, "Invalid total events");
        require(
            _vestingDuration <= 120 && totalEvents > 0,
            "Invalid total events"
        );

        realToken = IERC20(_realToken);

        SafeERC20.safeTransferFrom(
            realToken,
            msg.sender,
            address(this),
            _amount
        );

        lockedFund = _amount;
        totalEvents = _totalEvents;
        vestingDuration = _vestingDuration * uint32(30 days);
        eventSpan = vestingDuration / totalEvents;
        startTime = uint32(block.timestamp);
        lastUnlockTime = startTime;
        uint256 lockedAmountPerEvent = lockedFund / totalEvents;

        for (uint i = 1; i <= totalEvents; i++) {
            EventDetail memory eventDetail = EventDetail({
                eventNumber: i,
                lockedAmount: lockedAmountPerEvent,
                eventMaturityTime: (eventSpan * i) + block.timestamp,
                unlockStatus: false
            });

            eventDetails[i--] = eventDetail;
        }

        bytes memory __vestingMemo = abi.encodePacked(
            "Vesting started: ",
            _vestingMemo
        );
        memo.push(string(__vestingMemo));

        emit VestingStarted(
            lockedFund,
            totalEvents,
            vestingDuration,
            block.timestamp
        );
    }

    function unlockFund(
        string memory _vestingMemo
    )
        external
        onlyOwner
        returns (uint256 amountToSent, string memory evString)
    {
        require(
            totalEvents > matureEvents && lockedFund > unlockedFund,
            "unable to lock"
        );

        require(
            block.timestamp >= eventSpan + lastUnlockTime,
            "Time has not completed"
        );
        uint8 _matureEvents;
        uint arrayLen = eventDetails.length;
        string memory eventNumbers_ = "";
        bytes memory evBytes = new bytes(0);

        for (uint i; i < arrayLen; i++) {
            if (eventDetails[i].eventMaturityTime <= block.timestamp) {
                if (!eventDetails[i].unlockStatus) {
                    amountToSent += eventDetails[i].lockedAmount;
                    eventDetails[i].unlockStatus = true;
                    _matureEvents++;

                    bytes memory __eventsBytes = bytes(
                        eventDetails[i].eventNumber.toString()
                    );
                    bytes memory eventsBytesEn;
                    if (i < arrayLen - 1) {
                        eventsBytesEn = abi.encodePacked(__eventsBytes, ", ");
                    } else {
                        eventsBytesEn = abi.encodePacked(__eventsBytes);
                    }

                    evBytes = bytes.concat(evBytes, eventsBytesEn);
                }
            }
        }

        require(_matureEvents > 0, "No amount to unlock");
        matureEvents += _matureEvents;

        bytes memory __vestingMemo = abi.encodePacked(
            "Memo:- Events: ",
            evBytes.toString(),
            ", Unlocked amount: ",
            amountToSent,
            ", Unlock time: "(block.timestamp).toString(),
            ", ",
            _vestingMemo
        );

        evString = string(__vestingMemo);
        memo.push(evString);

        SafeERC20.safeTransfer(realToken, msg.sender, amountToSent);

        emit UnlockedEvent(amountToSent, matureEvents, unlockedTime);
        return (amountToSent, evString);
    }
}
