// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "contracts/IERC20.sol";

contract CrowdFund {

    event Launch(uint _id, address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    event Cancel(uint _id);
    event Pledge(uint indexed _id, address indexed sender, uint amount);
    event Unpledge(uint indexed _id, address indexed sender, uint amount);
    event Claim(uint _id);
    event Refund(uint indexed _id, address indexed sender, uint amount);

    //use the below snippet to get the current timestamp
    //new Date().getTime() / 1000
    //sample output - 1652588915.479
    //uint32 input == 1652588915

    struct Campaign{
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns; //keep track of number of campaigns
    mapping(uint => mapping(address => uint)) public pledgedAmount; //keep track of pledgedAmount in each campaign

    constructor(address _token){
        token = IERC20(_token);
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "_startAt < block.timestamp");
        require(_startAt < _endAt, "_startAt cannot be greater than _endTime");
        require(_endAt <= block.timestamp + 90 days, "Campaign should be less than 90 days");

        count += 1;

        campaigns[count] =  Campaign({
            creator: msg.sender, 
            goal : _goal,
            pledged: 0,
            startAt: _startAt,
            endAt:  _endAt,
            claimed: false
        });      

        emit Launch(count, msg.sender, _goal, _startAt, _endAt); 
    }

    function cancel(uint _id) external {
        //"memory" is used because we are not updating state variables
        Campaign memory campaign = campaigns[_id]; 
        require(msg.sender == campaign.creator, "missing authorization");
        require(campaign.startAt < block.timestamp, "Campaign already started");
        delete campaigns[_id];

        emit Cancel(_id); 
    }

    function pledge(uint _id, uint _amount) external {
        //"storage" is used because we are updating state variables
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign not started");
        require(block.timestamp <= campaign.endAt, "Campaign over");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
        
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "Campaign ended");
        
        require(pledgedAmount[_id][msg.sender] >= _amount, "pledgedAmount < _amount");
        campaign.pledged -= _amount;

        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "Campaign not ended");
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.claimed, "claimed already");

        campaign.claimed = true;
        
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Campaign not ended");
        require(!campaign.claimed, "claimed already");

        uint balance = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        
        token.transfer(msg.sender, balance);

        emit Refund(_id, msg.sender, balance);
    }
}


