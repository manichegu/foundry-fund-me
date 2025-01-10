//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test,console} from "forge-std/Test.sol";
import {FundContract} from "../../src/fundme.sol";
import {Deployfundme} from "../../script/fundme.s.sol";
import {Fundfundme,WithdrawfundMe} from "../../script/interactions.s.sol";
contract IntegrationTest is Test{
    FundContract obj;

    //Normal variables for testing :
    address USER=makeAddr("user");
    uint256 constant send_value=0.1 ether;
    uint256 constant starting_balance=10 ether;
    function setUp() external{
        Deployfundme deploy=new Deployfundme();
        obj=deploy.run();
        vm.deal(USER,starting_balance);
    }
    function testUserCanFund() external{
        Fundfundme fundfundme=new Fundfundme();
        fundfundme.fnFundfundme(address(obj));

        WithdrawfundMe withdrawfundMe=new WithdrawfundMe();
        withdrawfundMe.fnWithdrawfundMe(address(obj));
        assert(address(obj).balance==0);
    }
}
