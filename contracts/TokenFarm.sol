pragma solidity ^0.8.4;

import "./DecoToken.sol";
import "./DaiToken.sol";

import "hardhat/console.sol";

contract TokenFarm {
    string public name = "Deco Token Farm";
    uint public constant duration = 5 minutes;
    address public owner;
    DecoToken public decoToken;
    DaiToken public daiToken;

    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping(address => uint) public end;


    constructor(DecoToken _decoToken, DaiToken _daiToken) public {
        decoToken = _decoToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    function stakeTokens(uint _amount) public {
        // Require amount greater than 0
        require(_amount > 0, "amount cannot be 0");


        // Trasnfer Mock Dai tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        console.log('Block timestamp', block.timestamp, 'Duration', duration);
        end[msg.sender] = block.timestamp + duration;

        // Add user to stakers array *only* if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Unstaking Tokens (Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance
        uint balance = stakingBalance[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");
        console.log('Timestamp', block.timestamp);
        console.log('End', end[msg.sender]);
        require(block.timestamp > end[msg.sender], "cannot unstaking until at least 5 min after stake");

        // Transfer Mock Dai tokens to this contract for staking
        daiToken.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // Update staking status
        isStaking[msg.sender] = false;
    }

    // Issuing Tokens
    function issueTokens() public {
        // Only owner can call this function
        require(msg.sender == owner, "caller must be the owner");

        // Issue tokens to all stakers
        for (uint i=0; i<stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0) {
                decoToken.transfer(recipient, balance);
            }
        }
    }
}