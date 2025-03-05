// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ICO is Ownable, Pausable, ReentrancyGuard {
    struct UserData {
        address userAddress;
        uint256 amount;
    }

    UserData[] public usersData;
    mapping(address => uint256) public userAmount;
    IERC20 public token;

    constructor(address _token) payable Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function addTuples(UserData[] memory _usersData) public returns (bool) {
        for (uint256 i = 0; i < _usersData.length; i++) {
            usersData.push(_usersData[i]);
        }
        return true;
    }

    function addUserData(UserData[] memory _usersData) public returns (bool) {
        for (uint256 i = 0; i < _usersData.length; i++) {
            address _userAddress = _usersData[i].userAddress;
            uint256 _userAmount = _usersData[i].amount;

            userAmount[_userAddress] = _userAmount;
        }
        return true;
    }

    function claim(uint256 _amount) external whenNotPaused nonReentrant {
        require(
            token.balanceOf(address(this)) >= _amount,
            "ICO balance is low"
        );

        require(userAmount[msg.sender] >= _amount, "Put less amount");
        userAmount[msg.sender] -= _amount;

        require(token.transfer(msg.sender, _amount), "Transfer failed");
    }

    function claimLoop(uint256 _amount) external whenNotPaused nonReentrant {
        require(
            token.balanceOf(address(this)) >= _amount,
            "ICO balance is low"
        );

        for (uint256 i = 0; i < usersData.length; i++) {
            address _userAddress = usersData[i].userAddress;
            uint256 _userAmount = usersData[i].amount;

            if (_userAddress == msg.sender) {
                require(_userAmount >= _amount, "Put less amount");
                usersData[i].amount -= _amount;
                require(
                    token.transfer(msg.sender, _userAmount),
                    "Transfer failed"
                );

                break;
            }
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
