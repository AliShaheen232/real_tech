// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Vesting.sol";

contract VestingFactory is Ownable, ReentrancyGuard, Pausable {
    IERC20 public realToken;
    address[] public deployedContracts;
    uint256 public totalLocked;

    mapping(address => address[]) public contractsOwners;
    address[] public allowedTokens;

    event DeployedContracts(
        address indexed _contractAddress,
        address indexed _deployerAddress,
        uint256 _vestingAmount
    );

    constructor(
        address _initialOwner,
        address _realToken
    ) Ownable(_initialOwner) {
        realToken = IERC20(_realToken);
    }

    function deployVesting(
        uint256 _vestingAmount,
        uint8 _totalEvents,
        uint8 _vestingDuration,
        string memory _vestingMemo
    ) public nonReentrant whenNotPaused {
        Vesting deployedVesting = new Vesting(
            msg.sender,
            address(realToken),
            _vestingAmount,
            _totalEvents,
            _vestingDuration,
            _vestingMemo
        );

        address _vestingAddress = address(deployedVesting);
        deployedContracts.push(_vestingAddress);
        contractsOwners[msg.sender].push(_vestingAddress);
        totalLocked += _vestingAmount;

        SafeERC20.safeTransferFrom(
            realToken,
            msg.sender,
            _vestingAddress,
            _vestingAmount
        );

        emit DeployedContracts(_vestingAddress, msg.sender, _vestingAmount);
    }

    function pause() public whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    function getPaginatedDeployedAddresses(
        uint256 page,
        uint256 size
    ) public view returns (address[] memory _deployedAddresses) {
        uint256 ToSkip = page * size;
        uint256 count = 0;

        uint256 EndAt = deployedContracts.length > ToSkip + size
            ? ToSkip + size
            : deployedContracts.length;

        require(ToSkip < deployedContracts.length, "OVERFLOW_PAGE");
        require(EndAt > ToSkip, "OVERFLOW_PAGE");
        address[] memory result = new address[](EndAt - ToSkip);

        for (uint256 i = ToSkip; i < EndAt; i++) {
            result[count] = deployedContracts[
                (deployedContracts.length - 1) - i
            ];
            count++;
        }
        return result;
    }
}
