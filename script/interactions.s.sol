//SPDX-License-Identifier: MIT
//fund and with draw
pragma solidity ^0.8.18;
import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundContract} from "../src/fundme.sol";
contract Fundfundme is Script{
    uint256 constant SEND_VALUE=0.01 ether;
    function fnFundfundme(address mostRecentlyDeployed)public{
        vm.startBroadcast();
        FundContract(payable(mostRecentlyDeployed)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        console.log("funded fundme with %s",SEND_VALUE);
    }
    function run() external{
        address mostRecentlyDeployed=DevOpsTools.get_most_recent_deployment("fundme",block.chainid);
        fnFundfundme(mostRecentlyDeployed);
    }
}


contract WithdrawfundMe is Script{
    // uint256 constant SEND_VALUE=0.01 ether;
    function fnWithdrawfundMe(address mostRecentlyDeployed)public{
        vm.startBroadcast();
        FundContract(payable(mostRecentlyDeployed)).withDraw();
        vm.stopBroadcast();
    }
    function run() external{
        address mostRecentlyDeployed=DevOpsTools.get_most_recent_deployment("fundme",block.chainid);
        fnWithdrawfundMe(mostRecentlyDeployed);
    }
}

