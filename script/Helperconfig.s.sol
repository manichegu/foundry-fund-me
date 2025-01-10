//SPDX-Lisence_Identifier: MIT
// Note_IMP:
// helperconfig is generally used for two main purposes:
// 1.To keep track of the address of the different chains 
        // (i.e if forge test --rpc-url $Sepolia_URL/$Mainnet, 
        // To identify on which chain the user wants to work on and gives its adress)
// 2.To Deploy mock contracts when we are on a local anvil chain

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
contract Helperconfig is Script{
    //If we are on a local anvi;, we deploy mocks
    //Otherwise, grad the existing address from live network
    NetworkConfig public activeNetworkConfig;
    //variables used for mock functions i.e for anvilEthCOnfig:
    uint8 public constant decimals=8;
    int256 public constant initial_price=200e8;
    struct NetworkConfig{
        address pricefeed;
    }
    constructor(){
        if(block.chainid==11155111){
            activeNetworkConfig=getSepoliaEthConfig();
        }
        else if(block.chainid==1){
            activeNetworkConfig=getMainetEthConfig();
        }
        else{
            activeNetworkConfig=getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory sepoliaNetworkConfig=NetworkConfig({
            pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaNetworkConfig;
    }
    function getMainetEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory mainetNetworkConfig=NetworkConfig({
            pricefeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainetNetworkConfig;
    }
    function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
        if(activeNetworkConfig.pricefeed!=address(0)){
            return activeNetworkConfig;
        }
        //if nothing is passed automatically local anvil chain will spin up
        //1. Deploy the mocks;
        //2. Return the mock address;
        vm.startBroadcast();
        MockV3Aggregator mockpricefeed=new MockV3Aggregator(decimals,initial_price);
        vm.stopBroadcast();
        NetworkConfig memory anvilNetworkConfig=NetworkConfig({
            pricefeed:address(mockpricefeed)
        });
        return anvilNetworkConfig;
    }
}