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
        // TODO:
        //  1. check minimal duration
        //  2. create new campaign
    }


    function cancel(uint _id) external {
        // TODO:
        //  1. check that only creator is caller
        //  2. check that campaign has not started
        //  3. delete campaign
    }

    function pledge(uint _id, uint _amount) external {
        // TODO:
        // 1. check that campaign is active
        // 2. update caller pledged amount
        // 3. update total pledged amount
        // 4. transfer tokens from caller to this contract
    }

    function unpledge(uint _id, uint _amount) external {
        // 1. check that campaign is active
        // 2. update caller pledged amount
        // 3. update total pledged amount
        // 4. transfer tokens from this contract to caller
    }

    function claim(uint _id) external {
        // 1. check that the creator of the campaign is caller
        // 2. check that the campaign has ended
        // 3. check that the funding was succesful
        // 4. check that funds were not claimed already
        // 5. transfer tokens from contract to caller
    }

    function refund(uint _id) external {
        // 1. check that the campaign has ended
        // 2. checked that the funding was not succesful
        // 3. update caller pledged amount
        // 4. update total pledged amount
        // 5. transfer tokens from contract to caller
    }
}