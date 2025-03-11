// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract REALtest003 is Ownable, ReentrancyGuard, Pausable {
    uint256 public HARDCAP;
    uint256 public totalDeposited;
    uint64 public icoDuration; // in seconds
    uint64 public icoStartTime;

    AggregatorV3Interface internal priceFeed;

    IERC20 public immutable real;
    IERC20 public immutable usdt;
    IERC20 public immutable usdc;
    IERC20 public immutable dai;

    mapping(uint32 => mapping(address => uint256)) public userDeposited;
    mapping(uint32 => mapping(address => bool)) public userClaimed;

    struct Stage {
        uint64 timeToStart;
        uint64 timeToEnd;
        uint64 timeToClaim;
        uint256 totalETHCollected;
        uint256 totalUSDTCollected;
        uint256 totalUSDCCollected;
        uint256 totalDAICollected;
        uint256 price;
    }

    Stage[] public stages;

    receive() external payable {}

    fallback() external payable {}

    modifier validStage(uint32 _stageId) {
        require(_stageId < stages.length, "Presale: Invalid stage ID");
        _;
    }

    constructor(
        address _real,
        address _usdt,
        address _usdc,
        address _dai,
        uint256 _hardCAP
    ) Ownable(msg.sender) {
        // priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        real = IERC20(_real);
        usdt = IERC20(_usdt);
        usdc = IERC20(_usdc);
        dai = IERC20(_dai);
        HARDCAP = _hardCAP;
    }

    function startICO(uint64 _icoDuration) external onlyOwner {
        icoDuration = _icoDuration;
        icoStartTime = uint64(block.timestamp);

        emit ICOStarted(
            icoStartTime,
            (icoStartTime + icoDuration),
            icoDuration
        );
    }

    function createStage(
        uint64 _timeToStart,
        uint64 _timeToEnd,
        uint64 _timeToClaim,
        uint256 _price
    ) external onlyOwner {
        stages.push(
            Stage({
                timeToStart: _timeToStart,
                timeToEnd: _timeToEnd,
                timeToClaim: _timeToClaim,
                totalETHCollected: 0,
                totalUSDTCollected: 0,
                totalUSDCCollected: 0,
                totalDAICollected: 0,
                price: _price
            })
        );

        emit StageCreated(
            uint32(stages.length - 1),
            _timeToStart,
            _timeToEnd,
            _timeToClaim,
            _price
        );
    }

    function updateStage(
        uint32 _stageId,
        uint64 _timeToStart,
        uint64 _timeToEnd,
        uint64 _timeToClaim,
        uint256 _price
    ) external onlyOwner validStage(_stageId) {
        Stage storage stage = stages[_stageId];
        stage.timeToStart = _timeToStart;
        stage.timeToEnd = _timeToEnd;
        stage.timeToClaim = _timeToClaim;
        stage.price = _price;

        emit StageUpdated(
            _stageId,
            _timeToStart,
            _timeToEnd,
            _timeToClaim,
            _price
        );
    }

    function buyREALWithETH(
        uint32 _stageId
    ) external payable whenNotPaused nonReentrant validStage(_stageId) {
        require(getStageStatus(_stageId), "Presale: In-active stage ID");
        require(getICOStatus(), "Presale: In-active ICO");

        Stage storage stage = stages[_stageId];

        require(msg.value > 0, "Presale: Should be greater than 0");

        (uint256 price, uint256 updatedAt) = getLatestETHPrice();
        require(price > 0, "Invalid price feed data");
        require(block.timestamp - updatedAt < 1 hours, "Stale price");

        // uint256 depositedAmount = (msg.value *
        //     uint256(price) *
        //     DENOMINATOR *
        //     (10 ** real.decimals())) /
        //     (stage.price * (10 ** usdt.decimals()) * (10 ** 26));

        uint256 depositedAmount = (msg.value * price) /
            (stage.price * 10 ** real.decimals());

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalETHCollected += msg.value;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithETH(
            msg.sender,
            _stageId,
            msg.value,
            userDeposited[_stageId][msg.sender]
        );
    }

    function buyREALWithUSDT(
        uint32 _stageId,
        uint256 _amount
    ) external whenNotPaused nonReentrant validStage(_stageId) {
        require(getStageStatus(_stageId), "Presale: In-active stage ID");
        require(getICOStatus(), "Presale: In-active ICO");

        Stage storage stage = stages[_stageId];

        require(_amount > 0, "Presale: Should be greater than 0");
        SafeERC20.safeTransferFrom(
            IERC20(address(usdt)),
            msg.sender,
            address(this),
            _amount
        );

        // uint256 depositedAmount = (_amount *
        //     DENOMINATOR *
        //     (10 ** real.decimals())) / (stage.price * 10 ** usdt.decimals());

        uint256 depositedAmount = (_amount * (10 ** real.decimals())) /
            (stage.price * 10 ** usdt.decimals());

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalUSDTCollected += _amount;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithUSDT(
            msg.sender,
            _stageId,
            _amount,
            userDeposited[_stageId][msg.sender]
        );
    }

    function buyREALWithUSDC(
        uint32 _stageId,
        uint256 _amount
    ) external whenNotPaused nonReentrant validStage(_stageId) {
        require(getStageStatus(_stageId), "Presale: In-active stage ID");
        require(getICOStatus(), "Presale: In-active ICO");

        Stage storage stage = stages[_stageId];

        require(_amount > 0, "Presale: Should be greater than 0");
        SafeERC20.safeTransferFrom(
            IERC20(address(usdc)),
            msg.sender,
            address(this),
            _amount
        );

        // uint256 depositedAmount = (_amount *
        //     DENOMINATOR *
        //     (10 ** real.decimals())) / (stage.price * 10 ** usdc.decimals());

        uint256 depositedAmount = (_amount * (10 ** real.decimals())) /
            (stage.price * 10 ** usdc.decimals());

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalUSDCCollected += _amount;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithUSDC(
            msg.sender,
            _stageId,
            _amount,
            userDeposited[_stageId][msg.sender]
        );
    }

    function buyREALWithDAI(
        uint32 _stageId,
        uint256 _amount
    ) external whenNotPaused nonReentrant validStage(_stageId) {
        require(getStageStatus(_stageId), "Presale: In-active stage ID");
        require(getICOStatus(), "Presale: In-active ICO");

        Stage storage stage = stages[_stageId];

        require(_amount > 0, "Presale: Should be greater than 0");
        SafeERC20.safeTransferFrom(
            IERC20(address(dai)),
            msg.sender,
            address(this),
            _amount
        );

        uint256 depositedAmount = (_amount * (10 ** real.decimals())) /
            (stage.price * 10 ** dai.decimals());

        userDeposited[_stageId][msg.sender] += depositedAmount;
        totalDeposited += depositedAmount;
        stage.totalDAICollected += _amount;

        require(totalDeposited <= HARDCAP, "Presale: Hardcap reached");

        emit REALPurchasedWithDAI(
            msg.sender,
            _stageId,
            _amount,
            userDeposited[_stageId][msg.sender]
        );
    }

    function claimREAL(
        uint32 _stageId
    ) external whenNotPaused nonReentrant validStage(_stageId) {
        Stage storage stage = stages[_stageId];
        require(
            block.timestamp > stage.timeToClaim,
            "Presale: Invalid claim time"
        );
        require(
            userDeposited[_stageId][msg.sender] > 0,
            "Presale: Invalid claim amount"
        );
        require(!userClaimed[_stageId][msg.sender], "Presale: Already claimed");

        userClaimed[_stageId][msg.sender] = true;

        SafeERC20.safeTransfer(
            IERC20(address(real)),
            msg.sender,
            userDeposited[_stageId][msg.sender]
        );

        emit REALClaimed(
            msg.sender,
            _stageId,
            userDeposited[_stageId][msg.sender],
            block.timestamp
        );
    }

    function getStageStatus(
        uint32 _stageId
    ) public view returns (bool _status) {
        if (
            block.timestamp >= uint256(stages[_stageId].timeToStart) &&
            block.timestamp <= uint256(stages[_stageId].timeToEnd)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function getICOStatus() public view returns (bool _status) {
        if (icoStartTime == 0 || block.timestamp < uint256(icoStartTime)) {
            return false;
        }

        if (totalDeposited >= HARDCAP) {
            return false;
        }

        if (block.timestamp > uint256(icoStartTime + icoDuration)) {
            return false;
        }
        return true;
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(
            address(this).balance >= amount,
            "Presale: Not enough ETH in contract"
        );
        payable(msg.sender).transfer(amount);

        emit ETHWithdrawn(amount);
    }

    function withdrawUSDT(uint256 amount) external onlyOwner {
        require(
            usdt.balanceOf(address(this)) >= amount,
            "Presale: Not enough USDT in contract"
        );
        SafeERC20.safeTransfer(IERC20(address(usdt)), msg.sender, amount);

        emit USDTWithdrawn(amount);
    }

    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(
            usdc.balanceOf(address(this)) >= amount,
            "Presale: Not enough USDC in contract"
        );
        SafeERC20.safeTransfer(IERC20(address(usdc)), msg.sender, amount);

        emit USDCWithdrawn(amount);
    }

    function withdrawREAL(uint256 amount) external onlyOwner {
        require(
            real.balanceOf(address(this)) >= amount,
            "Presale: Not enough REAL in contract"
        );
        SafeERC20.safeTransfer(IERC20(address(real)), msg.sender, amount);

        emit REALWithdrawn(amount);
    }

    function getLatestETHPrice() public view returns (uint256, uint256) {
        (, int256 price, , uint256 updatedAt, ) = priceFeed.latestRoundData();
        return ((uint256(price) * 10 ** 10), updatedAt); // Convert to 18 decimals
    }

    event ICOStarted(
        uint64 _icoStartTime,
        uint64 _icoEndTime,
        uint64 _icoDuration
    );
    event StageCreated(
        uint32 indexed _stageId,
        uint64 _timeToStart,
        uint64 _timeToEnd,
        uint64 _timeToClaim,
        uint256 _price
    );
    event StageUpdated(
        uint32 indexed _stageId,
        uint64 _timeToStart,
        uint64 _timeToEnd,
        uint64 _timeToClaim,
        uint256 _price
    );
    event REALPurchasedWithETH(
        address indexed _user,
        uint32 indexed _stage,
        uint256 _baseAmount,
        uint256 _quoteAmount
    );
    event REALPurchasedWithUSDT(
        address indexed _user,
        uint32 indexed _stage,
        uint256 _baseAmount,
        uint256 _quoteAmount
    );
    event REALPurchasedWithUSDC(
        address indexed _user,
        uint32 indexed _stage,
        uint256 _baseAmount,
        uint256 _quoteAmount
    );
    event REALPurchasedWithDAI(
        address indexed _user,
        uint32 indexed _stage,
        uint256 _baseAmount,
        uint256 _quoteAmount
    );
    event REALClaimed(
        address indexed _user,
        uint32 indexed _stage,
        uint256 _amount,
        uint256 _timeStamp
    );
    event ETHWithdrawn(uint256 _amount);
    event USDTWithdrawn(uint256 _amount);
    event USDCWithdrawn(uint256 _amount);
    event REALWithdrawn(uint256 _amount);
}

// DAI decimals = 18
// USDT decimals = 6
// USDC decimals = 6
