//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
library priceConvertor{
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data"); // Ensure price is valid
        return uint256(price * 1e10); // ETH price in USD with 18 decimals
    }

    function getConversionRate(uint256 ethAmount,AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        return (ethAmount * ethPrice) / 1e18; // Convert ETH to USD
    }
}