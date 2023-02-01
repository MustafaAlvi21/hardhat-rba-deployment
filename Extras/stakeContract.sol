// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract stakeContract{
    using SafeMath for uint256;
    struct staker{
        uint256 stakeAt;
        uint256 totalStaked;
        uint256 totalClaimed;
        uint256 lastClaimed;
    }
    mapping(address => staker) public _staked;
    uint256 public totalStaked;
    uint256 public totalActiveStakers;
    uint256 public apyPercentage;
    address private owner;
    IERC20 public TokenAddress;

    constructor(address _tokenAddress, uint256 _apyPercentage){
        owner = msg.sender;
        TokenAddress = IERC20(_tokenAddress);
        apyPercentage = _apyPercentage; // 100 --> 1%, 10 --> 0.1, 1 --> 0.01
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "only owner can execute");
        _;
    }



    function stake(uint256 amount) external {
        require(TokenAddress.balanceOf(msg.sender) >= amount);
        require(_staked[msg.sender].totalStaked == 0, "You are already a staker");
        TokenAddress.transferFrom(msg.sender, address(this), amount);
        totalActiveStakers++;
        //_staked[msg.sender] = staker(123,123,123,123);
        _staked[msg.sender].totalStaked += amount;
        _staked[msg.sender].stakeAt = block.timestamp;
        totalStaked += amount;
    }

    function unstake() external {
        require(_staked[msg.sender].totalStaked > 0, "You are not a staker");
        TokenAddress.transfer(msg.sender,_staked[msg.sender].totalStaked);
        claim();
        totalStaked -= _staked[msg.sender].totalStaked;
        _staked[msg.sender].totalStaked = 0;
        totalActiveStakers--;
    }

    function rewardPool() view public returns (uint256){
        return TokenAddress.balanceOf(address(this)) - totalStaked;
    }

    function updateAPY(uint256 _newAPY) external onlyOwner{
        apyPercentage = _newAPY;
    }

    function withdrawRewardPool(uint256 amount) external onlyOwner{
        require(rewardPool() > amount, "Insufficient Rewards To Withdraw");
        TokenAddress.transfer(msg.sender , amount);
    }

    function claimable(address _stakee) view public returns(uint256,uint256){

        require(_staked[_stakee].totalStaked != 0,"NOT A STAKER");
        uint256 claimableDays;
        if(_staked[_stakee].lastClaimed == 0){
            claimableDays = (block.timestamp - _staked[_stakee].stakeAt).div(1 days);
        }else{
            claimableDays = (block.timestamp - _staked[_stakee].lastClaimed).div(1 days);
        }
        uint256 perDayReward = apyPercentage.mul(_staked[_stakee].totalStaked).div(10000).div(365);
        return (claimableDays, perDayReward.mul(claimableDays));

    }

    function claim() public{
        require(_staked[msg.sender].totalStaked != 0,"NOT A STAKER");
        (uint256 claimabledays, uint256 claimableAmount) = claimable(msg.sender);
        require(claimableAmount != 0,"Zero Claimable");
        require(rewardPool() > claimableAmount, "Currently Reward Pool is Empty Try Again Later");

        TokenAddress.transfer(msg.sender, claimableAmount);
        if(_staked[msg.sender].lastClaimed == 0){
            _staked[msg.sender].lastClaimed = _staked[msg.sender].stakeAt + claimabledays.mul(1 days);
        }else{
            _staked[msg.sender].lastClaimed += claimabledays.mul(86400);
        }
        _staked[msg.sender].totalClaimed += claimableAmount;

    }

    function test(address _user, uint256 _rewardDay) external onlyOwner{
        _staked[_user].lastClaimed = block.timestamp - _rewardDay.mul(1 days);
    }
}