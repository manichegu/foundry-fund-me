//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundContract} from "../src/fundme.sol";
import {Helperconfig} from "./Helperconfig.s.sol";
contract Deployfundme is Script{
    function run()external returns (FundContract){
        Helperconfig helperconfig=new Helperconfig();
        address pricefeed=helperconfig.activeNetworkConfig();
        vm.startBroadcast();
        FundContract fundme=new FundContract(pricefeed);
        vm.stopBroadcast();
        return fundme;
    }
}
