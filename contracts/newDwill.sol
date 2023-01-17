//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TransferFailed();
error NeedsMoreThanZero();

contract newDwill {
    address public s_owner;
    address public s_updater;
    uint256 public s_duration;

    struct user {
        address userWallet;
        address beneficiaryWallet;
        address [] tokenList;
        uint256 deadline;
        bool isAlive;
    }
    mapping (address => user) public Users;

    constructor(uint256 _s_duration, address _updater){
        s_owner = msg.sender;
        s_duration = _s_duration;
        s_updater = _updater;
    }

    modifier onlyOwner {
        require(msg.sender == s_owner, "Only owner is authorized to call this function");
        _;
    }
    
    modifier onlyUpdater {
        require(msg.sender == s_updater, "Only updater is authorized to call this function");
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    function register(address _beneficiaryWallet, address [] memory _tokenList) external {
        //Need to take approval to spend funds in the client side for transferFunds function to work
        require(!Users[msg.sender].isAlive, "User already Registered");
        user storage newUser = Users[msg.sender];
        newUser.userWallet = msg.sender;
        newUser.beneficiaryWallet = _beneficiaryWallet;
        newUser.tokenList = _tokenList;
        newUser.deadline = block.timestamp + s_duration;
        newUser.isAlive = true;
    }


    function updateDeadline(address _userAddress) external onlyUpdater{
        require(Users[_userAddress].isAlive, "User does not exist or is dead");
        Users[_userAddress].deadline = block.timestamp + s_duration;
    }

    function updateInActiveUser(address _userAddress) external onlyUpdater{
        require(Users[_userAddress].isAlive, "User does not exist or is dead");
        Users[_userAddress].isAlive = false;
    }
    
    function transferFunds(address _deadAddress) external onlyUpdater{
        require(!Users[_deadAddress].isAlive, "User is still alive");
        for(uint i=0; i < Users[_deadAddress].tokenList.length; i++){
            
            bool success = IERC20(Users[_deadAddress].tokenList[i]).transferFrom(_deadAddress, Users[_deadAddress].beneficiaryWallet , IERC20(Users[_deadAddress].tokenList[i]).balanceOf(_deadAddress));
            if (!success) {
            revert TransferFailed();
        }
        }
    }

    function setDuration (uint256 _s_duration) public onlyOwner moreThanZero(_s_duration) {
        s_duration = _s_duration;
    }

    function setupdater (address _s_updater) public onlyOwner {
        s_updater = _s_updater;
    }
}