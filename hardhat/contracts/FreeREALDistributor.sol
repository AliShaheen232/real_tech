// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract FreeREALDistributor is Ownable, ReentrancyGuard, Pausable {
    uint256 public HARDCAP;
    uint256 public totalClaimed;
    uint256 claimableAmt;
    IERC20 public real;
    address public clientSigner;

    mapping(address => bool) public userClaimed;

    event REALClaimed(
        address indexed _user,
        uint256 _amount,
        uint256 _timeStamp
    );

    event REALWithdrawn(uint256 _amount);

    constructor(
        address _real,
        address _clientSigner,
        uint256 _claimableAmt,
        uint256 _hardCAP
    ) Ownable(msg.sender) {
        real = IERC20(_real);
        clientSigner = _clientSigner;
        claimableAmt = _claimableAmt;
        HARDCAP = _hardCAP;
    }

    function claimREAL(
        string calldata message,
        bytes calldata signature
    ) external whenNotPaused nonReentrant {
        require(!userClaimed[msg.sender], "Free tokens already claimed");

        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(bytes(message));
        address signer = ECDSA.recover(hash, signature);

        require(signer == clientSigner, "Invalid signer");

        require(
            real.balanceOf(address(this)) >= claimableAmt,
            "Contract have less REAL balance"
        );

        uint256 _amount = address(msg.sender).balance;
        require(_amount > 0, "No ETH balance!");

        require(claimableAmt > 0, "Set claimable amount");
        require(totalClaimed < HARDCAP, "Hardcap reached");

        totalClaimed += claimableAmt;
        userClaimed[msg.sender] = true;

        SafeERC20.safeTransfer(real, msg.sender, claimableAmt);

        emit REALClaimed(msg.sender, claimableAmt, block.timestamp);
    }

    function pause() public whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    // method `setHARDCAP`
    // @dev - for testing purpose only
    function setHARDCAP(uint256 hardcap) public onlyOwner {
        HARDCAP = hardcap;
    }

    function setClientSigner(address _clientSigner) public onlyOwner {
        clientSigner = _clientSigner;
    }

    function withdrawREAL(uint256 amount) external onlyOwner {
        require(
            real.balanceOf(address(this)) >= amount,
            "Not enough REAL in contract"
        );
        SafeERC20.safeTransfer(IERC20(address(real)), msg.sender, amount);

        emit REALWithdrawn(amount);
    }
}
