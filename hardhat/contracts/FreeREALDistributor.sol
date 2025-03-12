// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract FreeREALDistributor is Ownable, ReentrancyGuard, Pausable {
    uint16 public constant DENOMINATOR = 10000;
    uint256 public HARDCAP;
    uint256 public totalClaimed;
    IERC20 public real;
    uint16 public distPercentage; // must be in multiple of 100

    mapping(address => uint256) public userClaimedAmount;

    receive() external payable {}

    fallback() external payable {}

    event REALClaimed(
        address indexed _user,
        uint256 _amount,
        uint256 _timeStamp
    );

    event REALWithdrawn(uint256 _amount);

    constructor(
        address _real,
        uint256 _hardCAP,
        uint16 _distPercentage
    ) Ownable(msg.sender) {
        require(
            _distPercentage <= 4900,
            "Distribution percentage must be <= 49"
        );
        real = IERC20Metadata(_real);
        HARDCAP = _hardCAP;
        distPercentage = _distPercentage;
    }

    function claimREAL() external whenNotPaused nonReentrant {
        require(
            userClaimedAmount[msg.sender] == 0,
            "Free tokens already claimed"
        );

        uint256 _amount = real.balanceOf(msg.sender);
        require(_amount > 0, "Zero Real balance!");
        _amount = (_amount * distPercentage) / DENOMINATOR;

        require(
            (totalClaimed + _amount) <= HARDCAP,
            "Presale: Hardcap reached"
        );

        totalClaimed += _amount;
        userClaimedAmount[msg.sender] = _amount;

        SafeERC20.safeTransfer(real, msg.sender, _amount);

        emit REALClaimed(msg.sender, _amount, block.timestamp);
    }

    function withdrawREAL(uint256 amount) external onlyOwner {
        require(
            real.balanceOf(address(this)) >= amount,
            "Presale: Not enough REAL in contract"
        );
        SafeERC20.safeTransfer(IERC20(address(real)), msg.sender, amount);

        emit REALWithdrawn(amount);
    }

    function setDistPercentage(uint16 _distPercentage) public onlyOwner {
        require(
            _distPercentage <= 4900,
            "Distribution percentage must be <= 49"
        );
        distPercentage = _distPercentage;
    }

    // method `setHARDCAP`
    // @dev - for testing purpose only
    function setHARDCAP(uint256 hardcap) public onlyOwner {
        HARDCAP = hardcap;
    }

    // method `setICODuration`
    // @dev - for testing purpose only
    function setICODuration(uint64 _icoDuration) public onlyOwner {
        icoDuration = _icoDuration;
    }
}
