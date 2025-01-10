// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {priceConvertor} from "./priceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//Note : make to set environment to Injected Provider-Metamask if not u will get err
contract FundContract {
    using priceConvertor for uint256;
    uint256 public minUSD = 0.01 * 1e18; // Minimum amount in USD scaled to 18 decimals
    address[] public funders;
    mapping(address add => uint256 amnt) public Funders_Totamount;
    address public owner;
    AggregatorV3Interface priceFeed_;
    constructor(address priceFeed){
        owner=msg.sender;
        priceFeed_=AggregatorV3Interface(priceFeed);
    }
    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed_) >= minUSD, "Not enough ETH sent");
        funders.push(msg.sender);
        Funders_Totamount[msg.sender]+=msg.value;
    }
    function getversion() public view returns(uint256){
        return priceFeed_.version();
    }
    //with draw function cannot be called by everyone right!!
    //it should be a owner;
    function withDraw()public Owner{
        uint256 funders_length=funders.length;
        for(uint256 i=0;i<funders_length;i++){
            address funder=funders[i];
            Funders_Totamount[funder]=0;
        }
        funders=new address[](0);
        (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"Call failed!!");
    }
    modifier Owner(){
        require(msg.sender==owner,"You are not the Owner!!");
        _;//here this "_" represents the execution of the rest of the code in the function i.e
          //require statement will executed first before any other line in the function-
          //where the Modifier is used; 
    }
    receive() external payable {
        fund(); // Call the `fund` function when Ether is sent without data.
    }
    fallback() external payable {
        fund(); // Call the `fund` function when Ether is sent with unrecognized data/function call.
    }
    //To make Gas efficient code public variable are change_d to private and to access them use functions:
    function getAddToAmountFunded(address fundingAdd)external view returns(uint256){
        return Funders_Totamount[fundingAdd];
    }
    function getFunder(uint256 index) external view returns (address){
        return funders[index];
    }
    function getOwner()external view returns(address){
        return owner;
    }
}
