// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

//AggregatorV3Interface is a datafeed that helps us get latest prices of any asset via chainlink
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// library do not contain state variables
// Why is this a library and not abstract? -> abstract contract that has some functions without their implementation
// and in our case we are defining the function defination so that it can be reused by other contracts without making any changes.
// Why not an interface? -> Interfaces are similar to abstract contracts and can not have any function with implementation and
// Functions of an interface can be only of type external.
library PriceConverter {

    function getPrice() internal view returns (uint256) {
        // https://docs.chain.link/docs/ethereum-addresses/
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            // Rinkeby ETH / USD smart contract Address
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit = wei
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        //gets the latest price from data feed
        uint256 ethPrice = getPrice();
        //gets the current value of ETH in USD
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
