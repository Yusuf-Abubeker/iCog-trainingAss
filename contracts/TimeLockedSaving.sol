// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockedSavings {
    struct Deposit {
        uint amount;
        uint releaseTime;
    }

    mapping(address => Deposit) public deposits;
    mapping(address => bool) public hasDeposit;

    event DepositMade(address indexed user, uint amount, uint releaseTime);
    event WithdrawalMade(address indexed user, uint amount);

    function makeDeposit(uint _releaseTime) public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        require(_releaseTime > block.timestamp, "Release time must be in the future");
        require(!hasDeposit[msg.sender], "Existing deposit must be withdrawn before making a new deposit");

        deposits[msg.sender] = Deposit(msg.value, _releaseTime);
        hasDeposit[msg.sender] = true;
        
        emit DepositMade(msg.sender, msg.value, _releaseTime);
    }

    function withdraw() public {
        require(hasDeposit[msg.sender], "No deposit found for user");
        require(block.timestamp >= deposits[msg.sender].releaseTime, "Deposit is still time-locked");

        uint amount = deposits[msg.sender].amount;
        deposits[msg.sender].amount = 0;
        hasDeposit[msg.sender] = false;
        
        payable(msg.sender).transfer(amount);
        
        emit WithdrawalMade(msg.sender, amount);
    }

    function checkDeposit(address _user) public view returns (uint amount, uint releaseTime) {
        require(hasDeposit[_user], "No deposit found for user");
        Deposit memory deposit = deposits[_user];
        return (deposit.amount, deposit.releaseTime);
    }
}
