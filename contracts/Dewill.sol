//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error TransferFailed();
error NeedsMoreThanZero();

contract Dwill {
    address public s_owner;
    address public s_updater;
    uint256 public s_duration;
    uint256 public s_duration2;  //new --------------

    struct user {
        address userWallet;
        address beneficiaryWallet;
        address [] tokenList;
        uint256 deadline;   
        uint256 deadline2;    //new ------------
        bool isAlive;
        uint [] percent_list;
    }
    mapping (address => user) public Users;

    constructor(uint256 _s_duration,uint256 _s_duration2 , address _updater){
        s_owner = msg.sender;
        s_duration = _s_duration;
        s_duration2 = _s_duration2;    //new ------------
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

    function register(address _beneficiaryWallet, address [] memory _tokenList, uint[] memory _percentList) external {
        //Need to take approval to spend funds in the client side for transferFunds function to work
        require(!Users[msg.sender].isAlive, "User already Registered");
        user storage newUser = Users[msg.sender];
        newUser.userWallet = msg.sender;
        newUser.beneficiaryWallet = _beneficiaryWallet;
        newUser.tokenList = _tokenList;
        newUser.deadline = block.timestamp + s_duration;
        newUser.deadline2 = block.timestamp + s_duration2;  //new ------------
        newUser.isAlive = true;
        newUser.percent_list = _percentList;   //new ------------
    }


    function updateDeadline(address _userAddress) external onlyUpdater{
        require(Users[_userAddress].isAlive, "User does not exist or is dead");
        Users[_userAddress].deadline = block.timestamp + s_duration;
        Users[_userAddress].deadline2 = block.timestamp + s_duration2; 
    }

    function updateInActiveUser1(address _userAddress) external onlyUpdater{        //new ------------
        require(Users[_userAddress].isAlive, "User does not exist or is dead");
        Users[_userAddress].isAlive = false;
    }

    // function updateInActiveUser2(address _userAddress) external onlyUpdater{        //new ------------
    //     require(Users[_userAddress].isAlive, "User does not exist or is dead");
    //     Users[_userAddress].isAlive = false;
    // }

    function transferFunds1(address _deadAddress) external onlyUpdater{     // new -------------
        require(!Users[_deadAddress].isAlive, "User is still alive");
        for(uint i=0; i < Users[_deadAddress].tokenList.length; i++){
            
            bool success = IERC20(Users[_deadAddress].tokenList[i]).transferFrom(_deadAddress, Users[_deadAddress].beneficiaryWallet , ((IERC20(Users[_deadAddress].tokenList[i]).balanceOf(_deadAddress))*(Users[_deadAddress].percent_list[i])/(100)));
            if (!success) {
            revert TransferFailed();
        }
        }
    }
    
    function transferFunds2(address _deadAddress) external onlyUpdater{         //new ------------
        require(!Users[_deadAddress].isAlive, "User is still alive");
        for(uint i=0; i < Users[_deadAddress].tokenList.length; i++){
            
            bool success = IERC20(Users[_deadAddress].tokenList[i]).transferFrom(_deadAddress, Users[_deadAddress].beneficiaryWallet , IERC20(Users[_deadAddress].tokenList[i]).balanceOf(_deadAddress));
            if (!success) {
            revert TransferFailed();
        }
        }
    }

    function setDuration (uint256 _s_duration, uint256 _s_duration2) public onlyOwner moreThanZero(_s_duration) {
        s_duration = _s_duration;
        s_duration2 = _s_duration2;
    }

    function setupdater (address _s_updater) public onlyOwner {
        s_updater = _s_updater;
    }
}