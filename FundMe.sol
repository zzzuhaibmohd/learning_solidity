// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

//AggregatorV3Interface is a datafeed that helps us get latest prices of any asset via chainlink
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//Deployed Contract address on Rinkeby Network - https://rinkeby.etherscan.io/address/0x04FA450831761C5CbEE697e3FeC7f36310DE9197

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //addressToAmountFunded keeps track of the amount funded by each funder
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // immutable variables can be set only once during the constructor call
    address public immutable i_owner;
    // constant varaibles are stored as part of the bytecode rather than storage
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        // using the the require statement with string takes up more storage and gas costs
        // this is a gas optimization technique
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() payable onlyOwner public {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the funders array
        funders = new address[](0);
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    fallback() external payable {
        // fallback function is invoked when the end user invokes a function call which is not present
        // we are redirecting such calls to the fund function call
        // check if the calldata is present in the contract
        fund();
    }

    receive() external payable {
        // receive function handles the scenario where in a funder does not 
        // invoke the fund function call and sends ETH via Metamask
        // its get triggered when calldata is blank
        fund();
    }

}
