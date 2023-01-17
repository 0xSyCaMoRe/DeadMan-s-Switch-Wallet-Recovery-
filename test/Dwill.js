const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether');
}
const ether = tokens;

let dwill,token;
let deployer, updater, user;

describe('Dwill', () => {
    beforeEach(async () => {
        //Setup Accounts
        const accounts = await ethers.getSigners();
        deployer = accounts[0];
        updater = accounts[1];
        user = accounts[2];
        beneficiary = accounts[3];

        const Dwill = await hre.ethers.getContractFactory("Dwill");
        dwill = await Dwill.deploy(10000,20000 , updater.address);
        await dwill.deployed();
        console.log(`Dwill deployed to: ${dwill.address}`);

        const Token = await hre.ethers.getContractFactory("Token");
        token = await Token.deploy(user.address);
        await token.deployed();
        console.log(`Token deployed to: ${token.address}`);

    });

    describe('Register User', async()=>{
        let transaction;
        it('Registers the user', async ()=>{
            //check balance of customer before deposit
            balance = await token.balanceOf(user.address);
            console.log("Balance of customer is: ", balance/(10**18));

            // Approve and Register the user
            transaction = await token.connect(user).increaseAllowance(dwill.address, tokens(10000))
            transaction = await dwill.connect(user).register(beneficiary.address, [token.address], [50]);
            // console.log("User Registered. Receipt: ", transaction);

            //check if user is registered
            // transaction = await dwill.Users(user.address);
            // console.log("User Details: ", transaction);

            //check contract balance and user balance
            console.log("=========Before Death=========");
            transaction = await token.balanceOf(user.address);
            console.log("User balance:", Number(transaction)/1e18);
            transaction = await token.balanceOf(beneficiary.address);
            console.log("Beneficiary balance:", Number(transaction)/1e18);

            //check if user is registered
            transaction = await dwill.Users(user.address);
            

            //update Deadline
            transaction = await dwill.connect(updater).updateDeadline(user.address);
            // console.log("Updated Deadline:", transaction);
            

            //Set user as dead 1
            transaction = await dwill.connect(updater).updateInActiveUser1(user.address);

            //check if user is registered
            transaction = await dwill.Users(user.address);
            console.log("User Alive: ", transaction.isAlive);

            //transferFunds
            transaction = await dwill.connect(updater).transferFunds1(user.address);
            // console.log("transfer funds:", transaction);

            //check contract balance and user balance
            console.log("=========After Death 1=========");
            transaction = await token.balanceOf(user.address);
            console.log("User balance:", Number(transaction)/1e18);
            transaction = await token.balanceOf(beneficiary.address);
            console.log("Beneficiary balance:", Number(transaction)/1e18);

            // //Set user as dead 2
            // transaction = await dwill.connect(updater).updateInActiveUser2(user.address);

            //transferFunds
            transaction = await dwill.connect(updater).transferFunds2(user.address);

            console.log("=========After Death 2=========");
            transaction = await token.balanceOf(user.address);
            console.log("User balance:", Number(transaction)/1e18);
            transaction = await token.balanceOf(beneficiary.address);
            console.log("Beneficiary balance:", Number(transaction)/1e18);


        })

    })
});