// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract REALtest003 is Ownable {
    uint256 public constant DENOMINATOR = 10000;
    uint256 public nativeTokenPriceInUSDT = 2650 * 10 ** 18;
    uint256 public HARDCAP = 1_100_000 ether;
    AggregatorV3Interface internal priceFeed;
    
    IERC20Metadata public immutable real;
    IERC20Metadata public immutable usdt;
    IERC20Metadata public immutable usdc;

    struct Stage {
        uint256 timeToStart;
        uint256 timeToEnd;
        uint256 timeToClaim;
        uint256 totalETHCollected;
        uint256 totalUSDTCollected;
        uint256 totalUSDCCollected;
        uint256 price;
    }

    Stage[] public stages;

    mapping(uint256 => mapping(address => uint256)) public userDeposited;
    mapping(uint256 => mapping(address => bool)) public userClaimed;

    uint256 public totalDeposited;

    event StageCreated(uint256 indexed _stageId, uint256 _timeToStart, uint256 _timeToEnd, uint256 _timeToClaim, uint256 _price);
    event StageUpdated(uint256 indexed _stageId, uint256 _timeToStart, uint256 _timeToEnd, uint256 _timeToClaim, uint256 _price);
    event REALPurchasedWithETH(address indexed _user, uint256 indexed _stage, uint256 _baseAmount, uint256 _quoteAmount);
    event REALPurchasedWithUSDT(address indexed _user, uint256 indexed _stage, uint256 _baseAmount, uint256 _quoteAmount);
    event REALPurchasedWithUSDC(address indexed _user, uint256 indexed _stage, uint256 _baseAmount, uint256 _quoteAmount);
    event REALClaimed(address indexed _user, uint256 indexed _stage, uint256 _amount, uint256 _timeStamp);
    event ETHWithdrawn(uint256 _amount);
    event USDTWithdrawn(uint256 _amount);
    event USDCWithdrawn(uint256 _amount);
    event REALWithdrawn(uint256 _amount);

    receive() external payable {}

    fallback() external payable {}

    constructor(
        address _real,
        address _usdt,
        address _usdc
    ) Ownable(msg.sender) {
        // priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        real = IERC20Metadata(_real);
        usdt = IERC20Metadata(_usdt);
        usdc = IERC20Metadata(_usdc);
    }

    function createStage(
        uint256 _timeToStart,
        uint256 _timeToEnd,
        uint256 _timeToClaim,
        uint256 _price
    ) external onlyOwner {
        stages.push(Stage({
            timeToStart: _timeToStart,
            timeToEnd: _timeToEnd,
            timeToClaim: _timeToClaim,
            totalETHCollected: 0,
            totalUSDTCollected: 0,
            totalUSDCCollected: 0,
            price: _price
        }));

        emit StageCreated(stages.length - 1, _timeToStart, _timeToEnd, _timeToClaim, _price);
    }

    function updateStage(
        uint256 _stageId,
        uint256 _timeToStart,
        uint256 _timeToEnd,
        uint256 _timeToClaim,
        uint256 _price
    ) external onlyOwner {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        stage.timeToStart = _timeToStart;
        stage.timeToEnd = _timeToEnd;
        stage.timeToClaim = _timeToClaim;
        stage.price = _price;

        emit StageUpdated(_stageId, _timeToStart, _timeToEnd, _timeToClaim, _price);
    }

    function buyREALWithETH(uint256 _stageId) external payable {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        require(block.timestamp >= stage.timeToStart && block.timestamp <= stage.timeToEnd, "Presale: Not presale period");
        require(msg.value > 0, "Presale: Should be greater than 0");

        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed data");

        uint256 depositedAmount = (msg.value * uint256(price) * DENOMINATOR * (10 ** real.decimals())) / (stage.price * (10 ** usdt.decimals()) * (10 ** 26));

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalETHCollected += msg.value;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithETH(msg.sender, _stageId, msg.value, userDeposited[_stageId][msg.sender]);
    }

    function buyREALWithUSDT(uint256 _stageId, uint256 _amount) external {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        require(block.timestamp >= stage.timeToStart && block.timestamp <= stage.timeToEnd, "Presale: Not presale period");
        require(_amount > 0, "Presale: Should be greater than 0");
        SafeERC20.safeTransferFrom(IERC20(address(usdt)), msg.sender, address(this), _amount);

        uint256 depositedAmount = (_amount * DENOMINATOR * (10 ** real.decimals())) / (stage.price * 10 ** usdt.decimals());

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalUSDTCollected += _amount;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithUSDT(msg.sender, _stageId, _amount, userDeposited[_stageId][msg.sender]);
    }

    function buyREALWithUSDC(uint256 _stageId, uint256 _amount) external {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        require(block.timestamp >= stage.timeToStart && block.timestamp <= stage.timeToEnd, "Presale: Not presale period");
        require(_amount > 0, "Presale: Should be greater than 0");
        SafeERC20.safeTransferFrom(IERC20(address(usdc)), msg.sender, address(this), _amount);

        uint256 depositedAmount = (_amount * DENOMINATOR * (10 ** real.decimals())) / (stage.price * 10 ** usdc.decimals());

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalUSDCCollected += _amount;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithUSDC(msg.sender, _stageId, _amount, userDeposited[_stageId][msg.sender]);
    }

    function claimREAL(uint256 _stageId) external {
        require(_stageId < stages.length, "Presale: Invalid stage ID");

        Stage storage stage = stages[_stageId];
        require(block.timestamp > stage.timeToClaim, "Presale: Invalid claim time");
        require(userDeposited[_stageId][msg.sender] > 0, "Presale: Invalid claim amount");
        require(!userClaimed[_stageId][msg.sender], "Presale: Already claimed");

        userClaimed[_stageId][msg.sender] = true;
        
        SafeERC20.safeTransfer(IERC20(address(real)), msg.sender, userDeposited[_stageId][msg.sender]);

        emit REALClaimed(msg.sender, _stageId, userDeposited[_stageId][msg.sender], block.timestamp);
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Presale: Not enough ETH in contract");
        payable(msg.sender).transfer(amount);

        emit ETHWithdrawn(amount);
    }

    function withdrawUSDT(uint256 amount) external onlyOwner {
        require(usdt.balanceOf(address(this)) >= amount, "Presale: Not enough USDT in contract");
        SafeERC20.safeTransfer(IERC20(address(usdt)), msg.sender, amount);

        emit USDTWithdrawn(amount);
    }

    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(usdc.balanceOf(address(this)) >= amount, "Presale: Not enough USDC in contract");
        SafeERC20.safeTransfer(IERC20(address(usdc)), msg.sender, amount);
        
        emit USDCWithdrawn(amount);
    }

    function withdrawREAL(uint256 amount) external onlyOwner {
        require(real.balanceOf(address(this)) >= amount, "Presale: Not enough REAL in contract");
        SafeERC20.safeTransfer(IERC20(address(real)), msg.sender, amount);

        emit REALWithdrawn(amount);
    }

    function getLatestETHPrice() external view returns (uint256) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10 ** 10; // Convert to 18 decimals
    }
}
