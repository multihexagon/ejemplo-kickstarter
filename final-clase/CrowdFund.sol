// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

contract CrowdFund {
    struct Campaign {
        // Creator of campaign
        address creator;
        // Amount of tokens to raise
        uint goal;
        // Total amount pledged
        uint pledged;
        // Timestamp of start of campaign
        uint256 startAt;
        // Timestamp of end of campaign
        uint256 endAt;
        // True if goal was reached and creator has claimed the tokens.
        bool claimed;
        // Metadata of the campaign
        string metadataUri;
    }

    IERC20 public immutable token;
    // Total count of campaigns created.
    // It is also used to generate id for new campaigns.
    uint public count;
    // Mapping from id to Campaign
    mapping(uint => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint256 _duration, string memory _metadataUri) external {
        require(_duration <= 90 days, "duration too long");
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: block.timestamp,
            endAt: block.timestamp + _duration,
            claimed: false,
            metadataUri: _metadataUri
        });
    }


    function cancel(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(campaign.startAt > block.timestamp);

        delete campaigns[_id];
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.endAt > block.timestamp, "ended");
        require(campaign.startAt <= block.timestamp, "not started");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.endAt > block.timestamp, "ended");
        require(campaign.startAt <= block.timestamp, "not started");
        require(pledgedAmount[_id][msg.sender] >= _amount);
        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(campaign.endAt < block.timestamp, "not ended");
        require(campaign.pledged >= campaign.goal, "not funded");
        require(campaign.claimed == false, "already claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.endAt < block.timestamp, "no ended");
        require(campaign.pledged < campaign.goal, "not funded");

        uint bal = pledgedAmount[_id][msg.sender];
        require(bal > 0, "no balance");
        
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
    }
}