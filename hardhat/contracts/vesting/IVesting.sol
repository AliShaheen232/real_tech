// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IVesting {
    function initialize(
        address _realToken,
        uint256 _amount,
        uint8 _totalEvents,
        uint8 _vestingDuration,
        string memory _vestingMemo
    ) external;

    function unlockFund(
        string memory _vestingMemo
    ) external returns (uint256 amountToSent, string memory evString);
}
